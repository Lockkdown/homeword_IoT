/*
 * TinyFlashBang – Relay / LED Bulb control via MQTT
 *
 * GPIO 5 → Relay IN (active HIGH)
 *   • LED xanh trên board relay sáng khi relay hút
 *   • Bóng đèn LED 5W AC bật/tắt qua relay
 *
 * MQTT Topics:
 *   tiny/relay/command  → payload "ON" / "OFF"
 *   tiny/led/command    → payload "ON" / "OFF"
 *
 * WiFi SSID/Pass và Broker URL cấu hình qua:
 *   idf.py menuconfig  →  Example Configuration  →  Broker URL
 *   idf.py menuconfig  →  Example Connection Configuration (WiFi)
 */

#include <stdio.h>
#include <string.h>

#include "esp_event.h"
#include "esp_log.h"
#include "esp_netif.h"
#include "esp_system.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "mqtt_client.h"
#include "nvs_flash.h"
#include "protocol_examples_common.h"
#include "driver/gpio.h"
#include "driver/uart.h"
#include "esp_sleep.h"
#include "esp_timer.h"
#include <math.h>

/* ── PZEM Debug Flag ───────────────────────────────────────── */
#define PZEM_DEBUG 0  /* Set to 1 to enable diagnostic logs */

/* ── Config ──────────────────────────────────────────────── */
#define RELAY_GPIO          GPIO_NUM_21
#define TOUCH_GPIO          GPIO_NUM_3
#define TOPIC_RELAY         "tiny/relay/command"
#define TOPIC_LED           "tiny/led/command"
#define TOPIC_RELAY_STATE   "tiny/relay/state"

/* PZEM-004T Config */
#define PZEM_UART_NUM       UART_NUM_1
#define PZEM_TX_GPIO        GPIO_NUM_4   /* ESP32 TX → PZEM RX */
#define PZEM_RX_GPIO        GPIO_NUM_6   /* PZEM TX → ESP32 RX */
#define PZEM_BAUD           9600
#define PZEM_BUF_SIZE       256

/* MQTT Power Topics */
#define TOPIC_PWR_VOLTAGE   "tiny/power/voltage"
#define TOPIC_PWR_CURRENT   "tiny/power/current"
#define TOPIC_PWR_WATTS     "tiny/power/watts"
#define TOPIC_PWR_ENERGY    "tiny/power/energy"
#define TOPIC_PWR_FREQ      "tiny/power/frequency"
#define TOPIC_PWR_PF        "tiny/power/pf"

static const char *TAG = "TinyFlashBang";
static esp_mqtt_client_handle_t s_client = NULL;
static bool s_relay_state = false;  /* false=OFF, true=ON */

/* Forward declarations */
static void relay_set(bool on);

/* Touch switch debounce */
static esp_timer_handle_t s_debounce_timer = NULL;
static volatile bool s_touch_pending = false;

/* ── Touch switch functions ─────────────────────────────────── */
static void debounce_timer_callback(void* arg)
{
    if (s_touch_pending && gpio_get_level(TOUCH_GPIO) == 0) {
        /* Valid press detected */
        s_relay_state = !s_relay_state;
        relay_set(s_relay_state);
        
        /* Publish state if MQTT is ready */
        if (s_client) {
            esp_mqtt_client_publish(s_client, TOPIC_RELAY_STATE,
                                   s_relay_state ? "ON" : "OFF", 0, 1, 1);
        }
        
        ESP_LOGI(TAG, "Touch switch: relay %s", s_relay_state ? "ON" : "OFF");
    }
    s_touch_pending = false;
}

static IRAM_ATTR void touch_isr_handler(void* arg)
{
    if (!s_touch_pending) {
        s_touch_pending = true;
        esp_timer_start_once(s_debounce_timer, 50000);  /* 50ms */
    }
}

/* ── CRC16 Modbus ─────────────────────────────────────────── */
static uint16_t crc16_modbus(const uint8_t *data, size_t length)
{
    uint16_t crc = 0xFFFF;
    for (size_t i = 0; i < length; i++) {
        crc ^= data[i];
        for (uint8_t j = 0; j < 8; j++) {
            if (crc & 0x0001) {
                crc = (crc >> 1) ^ 0xA001;
            } else {
                crc >>= 1;
            }
        }
    }
    return crc;
}

/* ── Relay helper ─────────────────────────────────────────── */
static void relay_set(bool on)
{
    /* Relay 5V Active LOW điều khiển bằng 3.3V (Open-Drain):
     *   on=true  → Xuất mức 0 (GND) → dòng điện 5V chảy qua chân IN → Hút
     *   on=false → Xuất mức 1 (Float/z-state) → không có dòng điện → Nhả
     */
    gpio_hold_dis(RELAY_GPIO);
    gpio_set_level(RELAY_GPIO, on ? 0 : 1);
    gpio_hold_en(RELAY_GPIO);  
    ESP_LOGI(TAG, "Relay → %s (Open-Drain %s)", on ? "ON" : "OFF", on ? "LOW" : "FLOAT");
}

static void relay_gpio_init(void)
{
    gpio_config_t cfg = {
        .pin_bit_mask = (1ULL << RELAY_GPIO),
        .mode         = GPIO_MODE_OUTPUT_OD,   /* QUAN TRỌNG: OPEN-DRAIN */
        .pull_up_en   = GPIO_PULLUP_DISABLE,
        .pull_down_en = GPIO_PULLDOWN_DISABLE, /* Tắt hết pull để thả nổi hoàn toàn */
        .intr_type    = GPIO_INTR_DISABLE,
    };
    gpio_config(&cfg);
    gpio_set_level(RELAY_GPIO, 1);   /* HIGH (Float) = relay tắt lúc boot */
    gpio_hold_en(RELAY_GPIO);        /* Giữ trạng thái lơ lửng qua sleep */
}

/* ── Touch GPIO init ─────────────────────────────────────────── */
static void touch_gpio_init(void)
{
    /* Create debounce timer */
    esp_timer_create_args_t timer_args = {
        .callback = &debounce_timer_callback,
        .name = "touch_debounce"
    };
    ESP_ERROR_CHECK(esp_timer_create(&timer_args, &s_debounce_timer));
    
    /* Configure touch GPIO as input with interrupt */
    gpio_config_t cfg = {
        .pin_bit_mask = (1ULL << TOUCH_GPIO),
        .mode         = GPIO_MODE_INPUT,
        .pull_up_en   = GPIO_PULLUP_ENABLE,
        .pull_down_en = GPIO_PULLDOWN_DISABLE,
        .intr_type    = GPIO_INTR_NEGEDGE,  /* Falling edge */
    };
    ESP_ERROR_CHECK(gpio_config(&cfg));
    
    /* Install ISR service and add handler */
    ESP_ERROR_CHECK(gpio_install_isr_service(0));
    ESP_ERROR_CHECK(gpio_isr_handler_add(TOUCH_GPIO, touch_isr_handler, NULL));
    
    ESP_LOGI(TAG, "Touch GPIO initialized: %d", TOUCH_GPIO);
}

/* ── Relay state sync ─────────────────────────────────────────── */
static void relay_publish_state(void)
{
    if (s_client) {
        esp_mqtt_client_publish(s_client, TOPIC_RELAY_STATE,
                               s_relay_state ? "ON" : "OFF", 0, 1, 1);
        ESP_LOGI(TAG, "Published relay state: %s", s_relay_state ? "ON" : "OFF");
    }
}

/* ── PZEM UART init ─────────────────────────────────────────── */
static void uart_pzem_init(void)
{
    uart_config_t uart_cfg = {
        .baud_rate = PZEM_BAUD,
        .data_bits = UART_DATA_8_BITS,
        .parity    = UART_PARITY_DISABLE,
        .stop_bits = UART_STOP_BITS_1,
        .flow_ctrl = UART_HW_FLOWCTRL_DISABLE,
        .source_clk = UART_SCLK_DEFAULT,
    };
    ESP_ERROR_CHECK(uart_param_config(PZEM_UART_NUM, &uart_cfg));
    ESP_ERROR_CHECK(uart_set_pin(PZEM_UART_NUM,
                                 PZEM_RX_GPIO, PZEM_TX_GPIO,  /* swapped: RX=GPIO6, TX=GPIO4 */
                                 UART_PIN_NO_CHANGE, UART_PIN_NO_CHANGE));
    ESP_ERROR_CHECK(uart_driver_install(PZEM_UART_NUM, PZEM_BUF_SIZE,
                                        0, 0, NULL, 0));
    ESP_LOGI(TAG, "PZEM UART initialized: TX=%d RX=%d", PZEM_TX_GPIO, PZEM_RX_GPIO);
}

#if PZEM_DEBUG
/* ── PZEM UART Loopback Test ──────────────────────────────── */
static bool pzem_uart_loopback_test(void)
{
    uint8_t tx = 0xA5;
    uint8_t rx = 0;
    
    uart_write_bytes(PZEM_UART_NUM, (const char*)&tx, 1);
    vTaskDelay(pdMS_TO_TICKS(10));
    
    int len = uart_read_bytes(PZEM_UART_NUM, &rx, 1, pdMS_TO_TICKS(100));
    
    if (len == 1 && rx == tx) {
        ESP_LOGI(TAG, "PZEM UART LOOPBACK: PASS (sent %02X, received %02X)", tx, rx);
        return true;
    } else {
        ESP_LOGE(TAG, "PZEM UART LOOPBACK: FAIL (sent %02X, received %02X, len=%d)", 
                 tx, rx, len);
        return false;
    }
}
#endif

/* ── PZEM-004T read ─────────────────────────────────────────── */
static bool pzem_read(float *voltage, float *current, float *power,
                      float *energy, float *frequency, float *pf)
{
    uint8_t request[8] = {0xF8, 0x04, 0x00, 0x00, 0x00, 0x0A, 0x00, 0x00};
    uint16_t crc = crc16_modbus(request, 6);
    request[6] = crc & 0xFF;
    request[7] = (crc >> 8) & 0xFF;

#if PZEM_DEBUG
    ESP_LOGI(TAG, "PZEM TX: %02X %02X %02X %02X %02X %02X %02X %02X",
             request[0], request[1], request[2], request[3],
             request[4], request[5], request[6], request[7]);
#endif

    uart_flush(PZEM_UART_NUM);
    int written = uart_write_bytes(PZEM_UART_NUM, (const char*)request, 8);
    if (written != 8) {
        ESP_LOGW(TAG, "PZEM: write failed");
        return false;
    }

#if PZEM_DEBUG
    ESP_LOGI(TAG, "PZEM: written %d/8 bytes", written);
    vTaskDelay(pdMS_TO_TICKS(500));  /* Wait for PZEM to process */
#endif

    uint8_t response[25];
    int len = uart_read_bytes(PZEM_UART_NUM, response, 25, pdMS_TO_TICKS(1000));

#if PZEM_DEBUG
    if (len > 0) {
        char hexbuf[128] = {0};
        for (int i = 0; i < len && i < 25; i++) {
            snprintf(hexbuf + strlen(hexbuf), sizeof(hexbuf) - strlen(hexbuf), 
                     "%02X ", response[i]);
        }
        ESP_LOGI(TAG, "PZEM RX: received %d bytes: %s", len, hexbuf);
    } else {
        ESP_LOGW(TAG, "PZEM RX: no data received (timeout)");
    }
#endif

    if (len != 25) {
        ESP_LOGW(TAG, "PZEM: read %d bytes (expected 25)", len);
        return false;
    }

    if (response[0] != 0xF8 || response[1] != 0x04 || response[2] != 0x14) {
        ESP_LOGW(TAG, "PZEM: invalid header %02X %02X %02X", 
                 response[0], response[1], response[2]);
        return false;
    }

    uint16_t crc_rx = response[23] | (response[24] << 8);
    uint16_t crc_calc = crc16_modbus(response, 23);
    if (crc_rx != crc_calc) {
        ESP_LOGW(TAG, "PZEM: CRC mismatch %04X vs %04X", crc_rx, crc_calc);
        return false;
    }

    *voltage   = ((uint16_t)response[3] << 8 | response[4]) / 10.0f;
    *current   = ((uint32_t)response[5] << 24 | (uint32_t)response[6] << 16 |
                  (uint32_t)response[7] << 8  | response[8]) / 1000.0f;
    *power     = ((uint32_t)response[9] << 24 | (uint32_t)response[10] << 16 |
                  (uint32_t)response[11] << 8  | response[12]) / 10.0f;
    *energy    = ((uint32_t)response[13] << 24 | (uint32_t)response[14] << 16 |
                  (uint32_t)response[15] << 8  | response[16]) / 1000.0f;
    *frequency = ((uint16_t)response[17] << 8 | response[18]) / 10.0f;
    *pf        = ((uint16_t)response[19] << 8 | response[20]) / 100.0f;

    return true;
}

/* ── PZEM task ─────────────────────────────────────────────── */
static void pzem_task(void *pvParam)
{
    vTaskDelay(pdMS_TO_TICKS(5000));  /* Wait for MQTT connection */

    ESP_LOGI(TAG, "PZEM task started");

    while (1) {
        float voltage, current, power, energy, frequency, pf;
        if (pzem_read(&voltage, &current, &power, &energy, &frequency, &pf)) {
            /* Skip publishing if MQTT client not ready */
            if (s_client == NULL) {
                ESP_LOGW(TAG, "PZEM: MQTT client not ready");
                vTaskDelay(pdMS_TO_TICKS(2000));
                continue;
            }
            
            char buf[32];
            
            snprintf(buf, sizeof(buf), "%.1f", voltage);
            esp_mqtt_client_publish(s_client, TOPIC_PWR_VOLTAGE, buf, 0, 1, 0);
            
            snprintf(buf, sizeof(buf), "%.3f", current);
            esp_mqtt_client_publish(s_client, TOPIC_PWR_CURRENT, buf, 0, 1, 0);
            
            snprintf(buf, sizeof(buf), "%.1f", power);
            esp_mqtt_client_publish(s_client, TOPIC_PWR_WATTS, buf, 0, 1, 0);
            
            snprintf(buf, sizeof(buf), "%.3f", energy);
            esp_mqtt_client_publish(s_client, TOPIC_PWR_ENERGY, buf, 0, 1, 0);
            
            snprintf(buf, sizeof(buf), "%.1f", frequency);
            esp_mqtt_client_publish(s_client, TOPIC_PWR_FREQ, buf, 0, 1, 0);
            
            snprintf(buf, sizeof(buf), "%.2f", pf);
            esp_mqtt_client_publish(s_client, TOPIC_PWR_PF, buf, 0, 1, 0);

            ESP_LOGI(TAG, "PZEM: %.1fV %.3fA %.1fW %.3fkWh %.1fHz PF=%.2f",
                     voltage, current, power, energy, frequency, pf);
        } else {
            ESP_LOGW(TAG, "PZEM read failed");
        }
        
        vTaskDelay(pdMS_TO_TICKS(2000));
    }
}

/* ── MQTT event handler ───────────────────────────────────── */
static void mqtt_event_handler(void *arg, esp_event_base_t base,
                               int32_t event_id, void *event_data)
{
    esp_mqtt_event_handle_t event  = event_data;
    esp_mqtt_client_handle_t client = event->client;

    switch ((esp_mqtt_event_id_t)event_id) {

    case MQTT_EVENT_CONNECTED:
        ESP_LOGI(TAG, "MQTT Connected");
        esp_mqtt_client_subscribe(client, TOPIC_RELAY, 1);
        esp_mqtt_client_subscribe(client, TOPIC_LED,   1);
        ESP_LOGI(TAG, "Subscribed: %s, %s", TOPIC_RELAY, TOPIC_LED);
        
        /* Publish current relay state immediately */
        relay_publish_state();
        break;

    case MQTT_EVENT_DISCONNECTED:
        ESP_LOGW(TAG, "MQTT Disconnected");
        break;

    case MQTT_EVENT_DATA: {
        /* Null-terminate topic & data để so sánh */
        char topic[64]   = {0};
        char payload[16] = {0};

        int topic_len   = event->topic_len   < (int)(sizeof(topic)   - 1)
                          ? event->topic_len   : (int)(sizeof(topic)   - 1);
        int payload_len = event->data_len    < (int)(sizeof(payload) - 1)
                          ? event->data_len    : (int)(sizeof(payload) - 1);

        memcpy(topic,   event->topic, topic_len);
        memcpy(payload, event->data,  payload_len);

        ESP_LOGI(TAG, "MSG topic=%s  payload=%s", topic, payload);

        /* Cả 2 topic đều điều khiển cùng GPIO 5 */
        bool is_relay = strcmp(topic, TOPIC_RELAY) == 0;
        bool is_led   = strcmp(topic, TOPIC_LED)   == 0;

        if (is_relay || is_led) {
            if (strcmp(payload, "ON") == 0) {
                s_relay_state = true;
                relay_set(true);
                relay_publish_state();
            } else if (strcmp(payload, "OFF") == 0) {
                s_relay_state = false;
                relay_set(false);
                relay_publish_state();
            } else {
                ESP_LOGW(TAG, "Unknown payload: %s", payload);
            }
        }
        break;
    }

    case MQTT_EVENT_ERROR:
        ESP_LOGE(TAG, "MQTT Error");
        break;

    default:
        break;
    }
}

/* ── Entry point ──────────────────────────────────────────── */
void app_main(void)
{
    /* NVS – required by WiFi */
    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES ||
        ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK(ret);

    /* GPIO relay */
    relay_gpio_init();

    /* Touch switch */
    touch_gpio_init();

    /* PZEM UART */
    uart_pzem_init();

    /* Note: Loopback test removed - not in checking project */

    ESP_ERROR_CHECK(esp_netif_init());
    ESP_ERROR_CHECK(esp_event_loop_create_default());
    ESP_ERROR_CHECK(example_connect()); /* WiFi từ menuconfig */

    /* MQTT */
    esp_mqtt_client_config_t mqtt_cfg = {
        .broker.address.uri = CONFIG_BROKER_URL,
    };
    esp_mqtt_client_handle_t client = esp_mqtt_client_init(&mqtt_cfg);
    s_client = client;
    esp_mqtt_client_register_event(client, ESP_EVENT_ANY_ID,
                                   mqtt_event_handler, NULL);
    esp_mqtt_client_start(client);

    /* Start PZEM monitoring task */
    xTaskCreate(pzem_task, "pzem", 4096, NULL, 5, NULL);

    ESP_LOGI(TAG, "TinyFlashBang started. Broker: %s", CONFIG_BROKER_URL);
}

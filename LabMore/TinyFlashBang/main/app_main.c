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
#include "esp_sleep.h"

/* ── Config ──────────────────────────────────────────────── */
#define RELAY_GPIO          GPIO_NUM_6
#define TOPIC_RELAY         "tiny/relay/command"
#define TOPIC_LED           "tiny/led/command"

static const char *TAG = "TinyFlashBang";

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
                relay_set(true);
            } else if (strcmp(payload, "OFF") == 0) {
                relay_set(false);
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


    ESP_ERROR_CHECK(esp_netif_init());
    ESP_ERROR_CHECK(esp_event_loop_create_default());
    ESP_ERROR_CHECK(example_connect()); /* WiFi từ menuconfig */

    /* MQTT */
    esp_mqtt_client_config_t mqtt_cfg = {
        .broker.address.uri = CONFIG_BROKER_URL,
    };
    esp_mqtt_client_handle_t client = esp_mqtt_client_init(&mqtt_cfg);
    esp_mqtt_client_register_event(client, ESP_EVENT_ANY_ID,
                                   mqtt_event_handler, NULL);
    esp_mqtt_client_start(client);

    ESP_LOGI(TAG, "TinyFlashBang started. Broker: %s", CONFIG_BROKER_URL);
}

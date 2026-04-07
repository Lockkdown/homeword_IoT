ESP_LOGI(TAG, "Cong tac: %s -> %s",
                            relay_state ? "ON" : "OFF",
                            relay_state ? "OFF" : "ON");
                    set_relay(!relay_state);
                    last_state = current_state;
                    vTaskDelay(pdMS_TO_TICKS(300));
                }
            }
            vTaskDelay(pdMS_TO_TICKS(20));
        }
    }

    // ========== TASK TELEMETRY ==========
    static void telemetry_task(void *arg) {
        while (1) {
            vTaskDelay(pdMS_TO_TICKS(TELEMETRY_INTERVAL_MS));
            if (!mqtt_client) continue;

            pzem_data_t data = pzem_read();
            char payload[256];

            if (data.valid) {
                snprintf(payload, sizeof(payload),
                    "{\"device_id\":\"%s\","
                    "\"voltage\":%.1f,\"current\":%.3f,"
                    "\"power\":%.1f,\"energy\":%.0f,"
                    "\"frequency\":%.1f,\"power_factor\":%.2f,"
                    "\"status\":\"%s\"}",
                    DEVICE_ID,
                    data.voltage, data.current, data.power,
                    data.energy, data.frequency, data.power_factor,
                    relay_state ? "ON" : "OFF");
            } else {
                snprintf(payload, sizeof(payload),
                    "{\"device_id\":\"%s\","
                    "\"voltage\":0,\"current\":0,\"power\":0,"
                    "\"energy\":0,\"frequency\":0,\"power_factor\":0,"
                    "\"status\":\"%s\"}",
                    DEVICE_ID, relay_state ? "ON" : "OFF");
            }

            esp_mqtt_client_publish(mqtt_client, TOPIC_TELEMETRY,
                                    payload, 0, 1, 0);
        }
    }

    // ========== IN QR CODE ==========
    static void print_qr_code(const char *service_name) {
        char payload[200] = {0};
        snprintf(payload, sizeof(payload),
                "{\"ver\":\"%s\",\"name\":\"%s\","
                "\"pop\":\"%s\",\"transport\":\"%s\"}",
                PROV_QR_VERSION, service_name,
                PROV_POP, PROV_TRANSPORT);

        ESP_LOGI(TAG, "=== QUET MA QR DE CAU HINH WIFI ===");
        ESP_LOGI(TAG, "Ten WiFi AP: %s", service_name);
        ESP_LOGI(TAG, "PIN: %s", PROV_POP);
        ESP_LOGI(TAG, "URL: %s?data=%s", QRCODE_BASE_URL, payload);

        esp_qrcode_config_t cfg = ESP_QRCODE_CONFIG_DEFAULT();
        esp_qrcode_generate(&cfg, payload);

        ESP_LOGI(TAG, "====================================");
    }

    // ========== EVENT HANDLER ==========
    static void event_handler(void *arg, esp_event_base_t base,
                           int32_t event_id, void *data) {
    if (base == WIFI_PROV_EVENT) {
        switch (event_id) {
        case WIFI_PROV_START:
            ESP_LOGI(TAG, "Provisioning bat dau...");
            break;
        case WIFI_PROV_CRED_RECV: {
            wifi_sta_config_t *cfg = (wifi_sta_config_t *)data;
    ESP_LOGW(TAG, "PZEM timeout! Nhan %d bytes", len);
            return result;
        }

        uint16_t recv_crc = buf[23] | (buf[24] << 8);
        uint16_t calc_crc = crc16(buf, 23);
        if (recv_crc != calc_crc) {
            ESP_LOGW(TAG, "PZEM CRC loi!");
            return result;
        }

        result.voltage      = ((uint16_t)(buf[3]  << 8 | buf[4]))  / 10.0f;
        result.current      = ((uint32_t)(buf[5]  << 8 | buf[6])  |
                            (uint32_t)(buf[7]  << 24| buf[8] << 16)) / 1000.0f;
        result.power        = ((uint32_t)(buf[9]  << 8 | buf[10]) |
                            (uint32_t)(buf[11] << 24| buf[12] << 16)) / 10.0f;
        result.energy       = ((uint32_t)(buf[13] << 8 | buf[14]) |
                            (uint32_t)(buf[15] << 24| buf[16] << 16)) / 1.0f;
        result.frequency    = ((uint16_t)(buf[17] << 8 | buf[18])) / 10.0f;
        result.power_factor = ((uint16_t)(buf[19] << 8 | buf[20])) / 100.0f;
        result.valid = true;

        ESP_LOGI(TAG, "PZEM: %.1fV | %.3fA | %.1fW | %.0fWh | %.1fHz | PF:%.2f",
                result.voltage, result.current, result.power,
                result.energy, result.frequency, result.power_factor);
        return result;
    }

    // ========== KHỞI TẠO PZEM ==========
    static void pzem_init(void) {
        uart_config_t uart_config = {
            .baud_rate  = PZEM_BAUD_RATE,
            .data_bits  = UART_DATA_8_BITS,
            .parity     = UART_PARITY_DISABLE,
            .stop_bits  = UART_STOP_BITS_1,
            .flow_ctrl  = UART_HW_FLOWCTRL_DISABLE,
        };
        ESP_ERROR_CHECK(uart_param_config(PZEM_UART_NUM, &uart_config));
        ESP_ERROR_CHECK(uart_set_pin(PZEM_UART_NUM,
                                    PZEM_RX_PIN, PZEM_TX_PIN,
                                    UART_PIN_NO_CHANGE, UART_PIN_NO_CHANGE));
        ESP_ERROR_CHECK(uart_driver_install(PZEM_UART_NUM, 256, 0, 0, NULL, 0));
        ESP_LOGI(TAG, "PZEM: RX=GPIO%d TX=GPIO%d", PZEM_RX_PIN, PZEM_TX_PIN);
    }

    // ========== SET RELAY ==========
    static void set_relay(bool on) {
        relay_state = on;
        gpio_set_level(RELAY_PIN, on ? RELAY_ON_LEVEL : RELAY_OFF_LEVEL);
        ESP_LOGI(TAG, "Relay: %s", on ? "ON" : "OFF");

        if (mqtt_client) {
            char payload[48];
            snprintf(payload, sizeof(payload),
                    "{\"status\":\"%s\"}", on ? "ON" : "OFF");
            esp_mqtt_client_publish(mqtt_client, TOPIC_STATUS, payload, 0, 1, 1);
        }
    }

    // ========== TASK BUTTON ==========
    static void button_task(void *arg) {
        int last_state = gpio_get_level(BUTTON_PIN);
        while (1) {
            int current_state = gpio_get_level(BUTTON_PIN);
            if (current_state != last_state) {
                vTaskDelay(pdMS_TO_TICKS(50));
                current_state = gpio_get_level(BUTTON_PIN);
                if (current_state != last_state) {

                    #include <stdio.h>
    #include <string.h>
    #include "freertos/FreeRTOS.h"
    #include "freertos/task.h"
    #include "freertos/event_groups.h"
    #include "esp_system.h"
    #include "esp_wifi.h"
    #include "esp_event.h"
    #include "esp_log.h"
    #include "nvs_flash.h"
    #include "nvs.h"
    #include "mqtt_client.h"
    #include "driver/gpio.h"
    #include "driver/uart.h"
    #include "wifi_provisioning/manager.h"
    #include "wifi_provisioning/scheme_softap.h"
    #include "qrcode.h"

    // ========== CẤU HÌNH ==========
    #define MQTT_BROKER_URI  "mqtt://broker.hivemq.com:1883"
    #define DEVICE_ID        "ESP32-001"

    #define RELAY_PIN        21
    #define BUTTON_PIN       3
    #define RELAY_ON_LEVEL   1
    #define RELAY_OFF_LEVEL  0

    // PZEM-004T
    #define PZEM_UART_NUM    UART_NUM_1
    #define PZEM_RX_PIN      6
    #define PZEM_TX_PIN      4
    #define PZEM_BAUD_RATE   9600
    #define PZEM_ADDR        0xF8

    #define TELEMETRY_INTERVAL_MS  5000

    // Provisioning
    #define PROV_QR_VERSION      "v1"
    #define PROV_TRANSPORT       "softap"
    #define PROV_POP             "abcd1234"
    #define QRCODE_BASE_URL      "https://espressif.github.io/esp-jumpstart/qrcode.html"
    // ==============================

    #define TOPIC_CONTROL    "device/" DEVICE_ID "/control"
    #define TOPIC_STATUS     "device/" DEVICE_ID "/status"
    #define TOPIC_TELEMETRY  "device/" DEVICE_ID "/telemetry"
    #define WIFI_CONNECTED_BIT BIT0

    static const char *TAG = "IOT_DEVICE";
    static EventGroupHandle_t wifi_event_group;
    static esp_mqtt_client_handle_t mqtt_client = NULL;
    static bool relay_state = false;

    // ========== CRC16 MODBUS ==========
    static uint16_t crc16(const uint8_t *buf, int len) {
        uint16_t crc = 0xFFFF;
        for (int i = 0; i < len; i++) {
            crc ^= buf[i];
            for (int j = 0; j < 8; j++) {
                if (crc & 0x0001) crc = (crc >> 1) ^ 0xA001;
                else crc >>= 1;
            }
        }
        return crc;
    }

    // ========== PZEM DATA ==========
    typedef struct {
        float voltage;
        float current;
        float power;
        float energy;
        float frequency;
        float power_factor;
        bool  valid;
    } pzem_data_t;

    // ========== ĐỌC PZEM ==========
    static pzem_data_t pzem_read(void) {
        pzem_data_t result = {0};
        uint8_t cmd[8] = {
            PZEM_ADDR, 0x04,
            0x00, 0x00,
            0x00, 0x0A,
            0x00, 0x00
        };
        uint16_t crc = crc16(cmd, 6);
        cmd[6] = crc & 0xFF;
        cmd[7] = (crc >> 8) & 0xFF;

        uart_flush(PZEM_UART_NUM);
        uart_write_bytes(PZEM_UART_NUM, (char *)cmd, sizeof(cmd));

        uint8_t buf[25] = {0};
        int len = uart_read_bytes(PZEM_UART_NUM, buf, sizeof(buf),
                                pdMS_TO_TICKS(500));
        if (len < 25) {
            ESP_LOGI(TAG, "Nhan WiFi: SSID=%s", (char *)cfg->ssid);
            break;
        }
        case WIFI_PROV_CRED_FAIL: {
            wifi_prov_sta_fail_reason_t *reason = (wifi_prov_sta_fail_reason_t *)data;
            ESP_LOGE(TAG, "Provisioning that bai: %s",
                     (*reason == WIFI_PROV_STA_AUTH_ERROR) ?
                     "Sai mat khau WiFi" : "Khong tim thay WiFi");
            wifi_prov_mgr_reset_sm_state_on_failure();
            break;
        }
        case WIFI_PROV_CRED_SUCCESS:
            ESP_LOGI(TAG, "Provisioning thanh cong!");
            break;
        case WIFI_PROV_END:
            wifi_prov_mgr_deinit();
            break;
        default:
            break;
        }
    } else if (base == WIFI_EVENT) {
        if (event_id == WIFI_EVENT_STA_START) {
            esp_wifi_connect();
        } else if (event_id == WIFI_EVENT_STA_DISCONNECTED) {
            wifi_event_sta_disconnected_t *disc =
                (wifi_event_sta_disconnected_t *)data;
            ESP_LOGW(TAG, "WiFi mat ket noi! Reason: %d", disc->reason);

            // Nếu sai mật khẩu → reset provisioning → restart
            if (disc->reason == WIFI_REASON_AUTH_FAIL ||
                disc->reason == WIFI_REASON_NO_AP_FOUND) {
                ESP_LOGE(TAG, "Sai mat khau hoac khong tim thay WiFi!");
                ESP_LOGE(TAG, "Reset provisioning - can cau hinh lai!");
                wifi_prov_mgr_reset_provisioning();
                vTaskDelay(pdMS_TO_TICKS(1000));
                esp_restart();
            }

            // Các lỗi khác → retry sau 2s
            vTaskDelay(pdMS_TO_TICKS(2000));
            esp_wifi_connect();
        }
    } else if (base == IP_EVENT && event_id == IP_EVENT_STA_GOT_IP) {
        ip_event_got_ip_t *event = (ip_event_got_ip_t *)data;
        ESP_LOGI(TAG, "WiFi OK! IP: " IPSTR, IP2STR(&event->ip_info.ip));
        xEventGroupSetBits(wifi_event_group, WIFI_CONNECTED_BIT);
    }
}

    // ========== KHỞI TẠO WIFI + PROVISIONING ==========
    static void wifi_init_provisioning(void) {
        wifi_event_group = xEventGroupCreate();

        ESP_ERROR_CHECK(esp_netif_init());
        ESP_ERROR_CHECK(esp_event_loop_create_default());
        esp_netif_create_default_wifi_sta();
        esp_netif_create_default_wifi_ap(); // Cần cho SoftAP provisioning

        // ← THÊM 2 DÒNG NÀY
        wifi_init_config_t wifi_cfg = WIFI_INIT_CONFIG_DEFAULT();
        ESP_ERROR_CHECK(esp_wifi_init(&wifi_cfg));

        ESP_ERROR_CHECK(esp_event_handler_register(
            WIFI_PROV_EVENT, ESP_EVENT_ANY_ID, &event_handler, NULL));
        ESP_ERROR_CHECK(esp_event_handler_register(
            WIFI_EVENT, ESP_EVENT_ANY_ID, &event_handler, NULL));
        ESP_ERROR_CHECK(esp_event_handler_register(
            IP_EVENT, IP_EVENT_STA_GOT_IP, &event_handler, NULL));

        // Dùng SoftAP scheme
        wifi_prov_mgr_config_t prov_config = {
            .scheme = wifi_prov_scheme_softap,
            .scheme_event_handler = WIFI_PROV_EVENT_HANDLER_NONE,
        };
        ESP_ERROR_CHECK(wifi_prov_mgr_init(prov_config));
        bool provisioned = false;
        ESP_ERROR_CHECK(wifi_prov_mgr_is_provisioned(&provisioned));

        if (!provisioned) {
            ESP_LOGI(TAG, "Chua co WiFi - Bat dau Provisioning qua SoftAP...");

            // Tạo tên AP từ MAC
            char service_name[16];
            uint8_t mac[6];
            esp_wifi_get_mac(WIFI_IF_STA, mac);
            snprintf(service_name, sizeof(service_name),
                    "PROV_%02X%02X%02X", mac[3], mac[4], mac[5]);

            wifi_prov_security_t security = WIFI_PROV_SECURITY_1;
            const char *pop = PROV_POP;

            ESP_ERROR_CHECK(wifi_prov_mgr_start_provisioning(
                security, pop, service_name, NULL));

            // In QR ra Serial Monitor
            print_qr_code(service_name);

            ESP_LOGI(TAG, "Ket noi WiFi vao: %s", service_name);
            ESP_LOGI(TAG, "Sau do dung app nhap PIN: %s", PROV_POP);

        } else {
            ESP_LOGI(TAG, "Da co WiFi - Ket noi truc tiep...");
            wifi_prov_mgr_deinit();
            ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA));
            ESP_ERROR_CHECK(esp_wifi_start());
        }

        xEventGroupWaitBits(wifi_event_group, WIFI_CONNECTED_BIT,
                            false, true, portMAX_DELAY);
        ESP_LOGI(TAG, "WiFi ket noi thanh cong!");
    }

    // ========== MQTT EVENT HANDLER ==========
    static void mqtt_event_handler(void *arg, esp_event_base_t base,
                                    int32_t event_id, void *data) {
        esp_mqtt_event_handle_t event = data;
        switch ((esp_mqtt_event_id_t)event_id) {
        case MQTT_EVENT_CONNECTED:
            ESP_LOGI(TAG, "MQTT ket noi thanh cong!");
            esp_mqtt_client_subscribe(mqtt_client, TOPIC_CONTROL, 1);
            set_relay(relay_state);
            break;
        case MQTT_EVENT_DISCONNECTED:
            ESP_LOGW(TAG, "MQTT mat ket noi!");
            break;
        case MQTT_EVENT_DATA: {
            char payload[64] = {0};
            strncpy(payload, event->data,
                    event->data_len < 63 ? event->data_len : 63);
            ESP_LOGI(TAG, "MQTT nhan: %s", payload);
            if (strstr(payload, "\"ON\"") || strcmp(payload, "ON") == 0) {
                set_relay(true);
            } else if (strstr(payload, "\"OFF\"") || strcmp(payload, "OFF") == 0) {
                set_relay(false);
            }
            break;
        }
        case MQTT_EVENT_ERROR:
            ESP_LOGE(TAG, "MQTT loi!");
            break;
        default:
            break;
        }
    }

    // ========== KHỞI TẠO MQTT ==========
    static void mqtt_init(void) {
        esp_mqtt_client_config_t mqtt_cfg = {
            .broker.address.uri = MQTT_BROKER_URI,
            .credentials.client_id = DEVICE_ID,
            .network.reconnect_timeout_ms = 5000,
        };
        
        
mqtt_client = esp_mqtt_client_init(&mqtt_cfg);
        esp_mqtt_client_register_event(mqtt_client, ESP_EVENT_ANY_ID,
                                    mqtt_event_handler, NULL);
        esp_mqtt_client_start(mqtt_client);
        ESP_LOGI(TAG, "MQTT: %s", MQTT_BROKER_URI);
    }

    // ========== APP MAIN ==========
    void app_main(void) {
        ESP_LOGI(TAG, "=== Khoi dong IoT Power Monitor ===");

        // 1. NVS
        esp_err_t ret = nvs_flash_init();
        if (ret == ESP_ERR_NVS_NO_FREE_PAGES ||
            ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
            ESP_ERROR_CHECK(nvs_flash_erase());
            ret = nvs_flash_init();
        }
        ESP_ERROR_CHECK(ret);

        // 2. PZEM
        pzem_init();

        // 3. Relay
        gpio_reset_pin(RELAY_PIN);
        gpio_set_level(RELAY_PIN, RELAY_OFF_LEVEL);
        gpio_set_direction(RELAY_PIN, GPIO_MODE_OUTPUT);
        ESP_LOGI(TAG, "Relay GPIO%d = OFF", RELAY_PIN);

        // 4. Button
        gpio_reset_pin(BUTTON_PIN);
        gpio_set_direction(BUTTON_PIN, GPIO_MODE_INPUT);
        gpio_set_pull_mode(BUTTON_PIN, GPIO_PULLUP_ONLY);
        ESP_LOGI(TAG, "Button GPIO%d OK", BUTTON_PIN);

        // 5. WiFi + Provisioning
        wifi_init_provisioning();

        // 6. MQTT
        mqtt_init();

        // 7. Tasks
        xTaskCreate(button_task,    "button",    4096, NULL, 5, NULL);
        xTaskCreate(telemetry_task, "telemetry", 4096, NULL, 5, NULL);

        ESP_LOGI(TAG, "=== He thong san sang! ===");
        ESP_LOGI(TAG, "Device: %s | Relay:GPIO%d | Button:GPIO%d",
                DEVICE_ID, RELAY_PIN, BUTTON_PIN);
    }
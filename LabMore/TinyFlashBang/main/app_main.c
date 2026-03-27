#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <inttypes.h>
#include "esp_system.h"
#include "nvs_flash.h"
#include "esp_event.h"
#include "esp_netif.h"
#include "protocol_examples_common.h"
#include "esp_log.h"
#include "mqtt_client.h"
#include "driver/gpio.h"

static const char *TAG = "tiny_flashbang";

#define TOPIC_COMMAND       "tiny/light/command"
#define TOPIC_BRIGHTNESS    "tiny/light/brightness"

static bool s_light_on = false;

static int relay_output_level(bool light_on)
{
    if (CONFIG_LIGHT_ACTIVE_LOW) {
        return light_on ? 0 : 1;
    }

    return light_on ? 1 : 0;
}

static void relay_init(void)
{
    gpio_config_t io_conf = {
        .pin_bit_mask = 1ULL << CONFIG_LIGHT_GPIO_PIN,
        .mode = GPIO_MODE_OUTPUT,
        .pull_up_en = GPIO_PULLUP_DISABLE,
        .pull_down_en = GPIO_PULLDOWN_DISABLE,
        .intr_type = GPIO_INTR_DISABLE,
    };

    ESP_ERROR_CHECK(gpio_config(&io_conf));
    ESP_ERROR_CHECK(gpio_set_level(CONFIG_LIGHT_GPIO_PIN, relay_output_level(false)));
}

static void update_light(void)
{
    int level = relay_output_level(s_light_on);
    ESP_LOGI(TAG, "Light %s | gpio=%d | level=%d", s_light_on ? "ON" : "OFF", CONFIG_LIGHT_GPIO_PIN, level);
    ESP_ERROR_CHECK(gpio_set_level(CONFIG_LIGHT_GPIO_PIN, level));
}

static void handle_command(const char *data, int len)
{
    if (len >= 2 && strncmp(data, "ON", len) == 0) {
        s_light_on = true;
    } else if (len >= 3 && strncmp(data, "OFF", len) == 0) {
        s_light_on = false;
    } else {
        ESP_LOGW(TAG, "Unknown command: %.*s", len, data);
        return;
    }
    update_light();
}

static void handle_brightness(const char *data, int len)
{
    ESP_LOGI(TAG, "Ignoring brightness command for relay output: %.*s", len, data);
}

static void log_error_if_nonzero(const char *message, int error_code)
{
    if (error_code != 0) {
        ESP_LOGE(TAG, "Last error %s: 0x%x", message, error_code);
    }
}

static bool topic_matches(esp_mqtt_event_handle_t event, const char *topic)
{
    size_t topic_len = strlen(topic);

    return event->topic_len == (int)topic_len && strncmp(event->topic, topic, topic_len) == 0;
}

static void mqtt_event_handler(void *handler_args, esp_event_base_t base, int32_t event_id, void *event_data)
{
    esp_mqtt_event_handle_t event = event_data;
    esp_mqtt_client_handle_t client = event->client;

    switch ((esp_mqtt_event_id_t)event_id) {
    case MQTT_EVENT_CONNECTED:
        ESP_LOGI(TAG, "MQTT_EVENT_CONNECTED");
        esp_mqtt_client_subscribe(client, TOPIC_COMMAND, 1);
        esp_mqtt_client_subscribe(client, TOPIC_BRIGHTNESS, 1);
        ESP_LOGI(TAG, "Subscribed to [%s] and [%s]", TOPIC_COMMAND, TOPIC_BRIGHTNESS);
        break;

    case MQTT_EVENT_DISCONNECTED:
        ESP_LOGI(TAG, "MQTT_EVENT_DISCONNECTED");
        break;

    case MQTT_EVENT_DATA:
        if (topic_matches(event, TOPIC_COMMAND)) {
            handle_command(event->data, event->data_len);
        } else if (topic_matches(event, TOPIC_BRIGHTNESS)) {
            handle_brightness(event->data, event->data_len);
        }
        break;

    case MQTT_EVENT_ERROR:
        ESP_LOGI(TAG, "MQTT_EVENT_ERROR");
        if (event->error_handle->error_type == MQTT_ERROR_TYPE_TCP_TRANSPORT) {
            log_error_if_nonzero("esp-tls", event->error_handle->esp_tls_last_esp_err);
            log_error_if_nonzero("tls stack", event->error_handle->esp_tls_stack_err);
            log_error_if_nonzero("socket errno", event->error_handle->esp_transport_sock_errno);
        }
        break;

    default:
        break;
    }
}

static void mqtt_app_start(void)
{
    esp_mqtt_client_config_t mqtt_cfg = {
        .broker.address.uri = CONFIG_BROKER_URL,
    };
    esp_mqtt_client_handle_t client = esp_mqtt_client_init(&mqtt_cfg);
    esp_mqtt_client_register_event(client, ESP_EVENT_ANY_ID, mqtt_event_handler, NULL);
    esp_mqtt_client_start(client);
}

void app_main(void)
{
    ESP_LOGI(TAG, "[APP] Startup..");
    ESP_LOGI(TAG, "[APP] Free memory: %" PRIu32 " bytes", esp_get_free_heap_size());
    ESP_LOGI(TAG, "[APP] IDF version: %s", esp_get_idf_version());

    esp_log_level_set("*", ESP_LOG_INFO);

    ESP_ERROR_CHECK(nvs_flash_init());
    ESP_ERROR_CHECK(esp_netif_init());
    ESP_ERROR_CHECK(esp_event_loop_create_default());
    ESP_ERROR_CHECK(example_connect());

    relay_init();
    mqtt_app_start();
}

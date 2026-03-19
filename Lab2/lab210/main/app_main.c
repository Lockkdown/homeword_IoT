#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include "esp_system.h"
#include "nvs_flash.h"
#include "esp_event.h"
#include "esp_netif.h"
#include "protocol_examples_common.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/semphr.h"
#include "freertos/queue.h"
#include "lwip/sockets.h"
#include "lwip/dns.h"
#include "lwip/netdb.h"
#include "esp_log.h"
#include "driver/gpio.h"
#include "mqtt_client.h"

static const char *TAG = "MQTT_EXAMPLE";
static const gpio_num_t LED_GPIO = GPIO_NUM_8;
#define LED_TOPIC "/topic/led/control"

static void led_init(void)
{
    gpio_config_t io_conf = {
        .pin_bit_mask = 1ULL << LED_GPIO,
        .mode = GPIO_MODE_OUTPUT,
        .pull_up_en = GPIO_PULLUP_DISABLE,
        .pull_down_en = GPIO_PULLDOWN_DISABLE,
        .intr_type = GPIO_INTR_DISABLE,
    };
    ESP_ERROR_CHECK(gpio_config(&io_conf));
    ESP_ERROR_CHECK(gpio_set_level(LED_GPIO, 0));
}

static void mqtt_event_handler(void *handler_args, esp_event_base_t base, int32_t event_id, void *event_data)
{
ESP_LOGD(TAG, "Event dispatched from event loop base=%s, event_id=%" PRIi32 "", base, event_id);
esp_mqtt_event_handle_t event = event_data;
esp_mqtt_client_handle_t client = event->client;
int msg_id;
switch ((esp_mqtt_event_id_t)event_id)
{
case MQTT_EVENT_CONNECTED:
ESP_LOGI(TAG, "MQTT_EVENT_CONNECTED");
msg_id = esp_mqtt_client_subscribe(client, LED_TOPIC, 1);
ESP_LOGI(TAG, "Subscribed to %s, msg_id=%d", LED_TOPIC, msg_id);
break;
case MQTT_EVENT_DISCONNECTED:
ESP_LOGI(TAG, "MQTT_EVENT_DISCONNECTED");
break;
case MQTT_EVENT_SUBSCRIBED:
ESP_LOGI(TAG, "MQTT_EVENT_SUBSCRIBED, msg_id=%d", event->msg_id);
break;
case MQTT_EVENT_UNSUBSCRIBED:
ESP_LOGI(TAG, "MQTT_EVENT_UNSUBSCRIBED, msg_id=%d", event->msg_id);
break;
case MQTT_EVENT_PUBLISHED:
ESP_LOGI(TAG, "MQTT_EVENT_PUBLISHED, msg_id=%d", event->msg_id);
break;
case MQTT_EVENT_DATA:
ESP_LOGI(TAG, "TOPIC=%.*s | DATA=%.*s", event->topic_len, event->topic, event->data_len, event->data);
if (event->data_len >= 1 && event->data[0] == '1')
{
gpio_set_level(LED_GPIO, 1);
ESP_LOGI(TAG, "LED ON");
}
else if (event->data_len >= 1 && event->data[0] == '0')
{
gpio_set_level(LED_GPIO, 0);
ESP_LOGI(TAG, "LED OFF");
}
break;
case MQTT_EVENT_ERROR:
ESP_LOGI(TAG, "MQTT_EVENT_ERROR");
break;
default:
ESP_LOGI(TAG, "Other event id:%d", event->event_id);
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
esp_log_level_set("mqtt_client", ESP_LOG_VERBOSE);
esp_log_level_set("MQTT_EXAMPLE", ESP_LOG_VERBOSE);
esp_log_level_set("TRANSPORT_BASE", ESP_LOG_VERBOSE);
esp_log_level_set("esp-tls", ESP_LOG_VERBOSE);
esp_log_level_set("TRANSPORT", ESP_LOG_VERBOSE);
esp_log_level_set("outbox", ESP_LOG_VERBOSE);
led_init();
ESP_ERROR_CHECK(nvs_flash_init());
ESP_ERROR_CHECK(esp_netif_init());
ESP_ERROR_CHECK(esp_event_loop_create_default());
ESP_ERROR_CHECK(example_connect());
mqtt_app_start();
}

#include "qr_generator.h"
#include "esp_log.h"
#include "esp_mac.h"
#include "qrcode.h"
#include <string.h>
#include <stdio.h>

static const char *TAG = "QR_GENERATOR";
extern const char *pop_data;

// Generate QR code for device provisioning
void generate_device_qr(void)
{
    uint8_t mac[6];
    char device_id[32];
    char qr_data[128];
    
    // Get MAC address as unique device ID
    esp_err_t ret = esp_read_mac(mac, ESP_MAC_WIFI_STA);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to read MAC address");
        return;
    }
    
    // Format device ID
    snprintf(device_id, sizeof(device_id), "esp32_%02X%02X%02X%02X", 
             mac[2], mac[3], mac[4], mac[5]);
    
    // Create QR data with BLE provisioning format
    // Format: {"ver":"v1","name":"PROV_SMARTLAMP","pop":"abcd1234","transport":"ble"}
    snprintf(qr_data, sizeof(qr_data), 
             "{\"ver\":\"v1\",\"name\":\"PROV_SMARTLAMP\",\"pop\":\"%s\",\"transport\":\"ble\"}", 
             pop_data);
    
    ESP_LOGI(TAG, "Device ID: %s", device_id);
    ESP_LOGI(TAG, "QR Data: %s", qr_data);
    ESP_LOGI(TAG, "Scan QR to provision:");
    
    // Generate QR code and print to serial
    ESP_LOGI(TAG, "┌─────────────────────────┐");
    ESP_LOGI(TAG, "│   QR CODE FOR DEVICE   │");
    ESP_LOGI(TAG, "└─────────────────────────┘");
    
    // Create QR code using ESP-IDF API
    esp_qrcode_config_t cfg = ESP_QRCODE_CONFIG_DEFAULT();
    esp_qrcode_generate(&cfg, qr_data);
    
    ESP_LOGI(TAG, "");
    ESP_LOGI(TAG, "Use your phone camera to scan this QR code");
    ESP_LOGI(TAG, "or manually enter: %s", device_id);
    ESP_LOGI(TAG, "PoP key: %s", pop_data);
    ESP_LOGI(TAG, "");
}

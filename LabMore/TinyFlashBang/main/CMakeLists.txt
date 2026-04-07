idf_component_register(SRCS "app_main.c" "qr_generator.c"
                    PRIV_REQUIRES mqtt nvs_flash esp_netif driver protocol_examples_common wifi_provisioning bt protocomm
                    INCLUDE_DIRS ".")

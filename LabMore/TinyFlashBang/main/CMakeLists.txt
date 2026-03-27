idf_component_register(SRCS "app_main.c"
                    PRIV_REQUIRES mqtt nvs_flash esp_netif driver protocol_examples_common
                    INCLUDE_DIRS ".")

idf_component_register(SRCS "hello_world_main.c"
                       PRIV_REQUIRES spi_flash esp_wifi esp_event nvs_flash esp_netif mqtt lwip protocol_examples_common
                       INCLUDE_DIRS "")

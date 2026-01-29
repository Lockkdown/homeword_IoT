
package com.truonghoangphuc.lab307.config;

import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.integration.annotation.IntegrationComponentScan;
import org.springframework.integration.annotation.ServiceActivator;
import org.springframework.integration.channel.DirectChannel;
import org.springframework.integration.mqtt.core.DefaultMqttPahoClientFactory;
import org.springframework.integration.mqtt.outbound.MqttPahoMessageHandler;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.MessageHandler;
import org.springframework.util.StringUtils;

@Configuration
@IntegrationComponentScan
public class MqttConfig {
    @Value("${mqtt.broker-url:tcp://localhost:1883}")
    private String brokerUrl;
    @Value("${mqtt.client-id:lab307-publisher}")
    private String clientId;
    @Value("${mqtt.username:}")
    private String username;
    @Value("${mqtt.password:}")
    private String password;
    @Value("${mqtt.topic}")
    private String defaultTopic;

    @Bean
    public DefaultMqttPahoClientFactory mqttClientFactory() {
        var factory = new DefaultMqttPahoClientFactory();
        var options = new MqttConnectOptions();
        if (!StringUtils.hasText(brokerUrl)) {
            throw new IllegalStateException("mqtt.broker-url is required");
        }
        if (!StringUtils.hasText(defaultTopic)) {
            throw new IllegalStateException("mqtt.topic is required");
        }
        options.setServerURIs(new String[] { brokerUrl });
        options.setAutomaticReconnect(true);
        options.setCleanSession(true);

        if (StringUtils.hasText(username)) {
            options.setUserName(username);
            options.setPassword(password == null ? null : password.toCharArray());
        }
        factory.setConnectionOptions(options);
        return factory;
    }

    @Bean
    public MessageChannel mqttOutboundChannel() {
        return new DirectChannel();
    }

    @Bean
    @ServiceActivator(inputChannel = "mqttOutboundChannel")
    public MessageHandler mqttOutbound() {
        var handler = new MqttPahoMessageHandler(clientId, mqttClientFactory());
        handler.setAsync(true);
        handler.setDefaultTopic(defaultTopic);
        return handler;
    }
}
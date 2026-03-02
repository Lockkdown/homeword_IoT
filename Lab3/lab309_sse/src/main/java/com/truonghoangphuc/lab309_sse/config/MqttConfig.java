
package com.truonghoangphuc.lab309_sse.config;

import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.integration.annotation.IntegrationComponentScan;
import org.springframework.integration.annotation.ServiceActivator;
import org.springframework.integration.channel.DirectChannel;
import org.springframework.integration.mqtt.core.DefaultMqttPahoClientFactory;
import org.springframework.integration.mqtt.inbound.MqttPahoMessageDrivenChannelAdapter;
import org.springframework.integration.mqtt.outbound.MqttPahoMessageHandler;
import org.springframework.integration.mqtt.support.DefaultPahoMessageConverter;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.MessageHandler;
import org.springframework.util.StringUtils;

import com.truonghoangphuc.lab309_sse.service.MqttSubscriberService;

@Configuration
@IntegrationComponentScan
public class MqttConfig {

    @Value("${mqtt.broker-url:tcp://localhost:1883}")
    private String brokerUrl;
    @Value("${mqtt.client-id:lab309-sse-publisher}")
    private String clientId;
    @Value("${mqtt.subscriber-client-id:lab309-sse-subscriber}")
    private String subscriberClientId;
    @Value("${mqtt.username:}")
    private String username;
    @Value("${mqtt.password:}")
    private String password;
    @Value("${mqtt.topic:/test/topic}")
    private String defaultTopic;
    @Value("${mqtt.subscribe-topics:/test/topic}")
    private String subscribeTopics;

    // ── Shared Factory ───────────────────────────────────────────────────────

    @Bean
    public DefaultMqttPahoClientFactory mqttClientFactory() {
        var factory = new DefaultMqttPahoClientFactory();
        var options = new MqttConnectOptions();
        if (!StringUtils.hasText(brokerUrl)) {
            throw new IllegalStateException("mqtt.broker-url is required");
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

    // ── Outbound (Publisher) ─────────────────────────────────────────────────

    @Bean
    public MessageChannel mqttOutboundChannel() {
        return new DirectChannel();
    }

    @Bean
    @ServiceActivator(inputChannel = "mqttOutboundChannel")
    public MessageHandler mqttOutbound() {
        var handler = new MqttPahoMessageHandler(clientId, mqttClientFactory());
        handler.setAsync(false);
        handler.setCompletionTimeout(10_000);
        handler.setDefaultTopic(defaultTopic);
        return handler;
    }

    // ── Inbound (Subscriber) ─────────────────────────────────────────────────

    @Bean
    public MessageChannel mqttInboundChannel() {
        return new DirectChannel();
    }

    @Bean
    public MqttPahoMessageDrivenChannelAdapter mqttInbound() {
        // Tách riêng client-id để publisher và subscriber không xung đột
        var topics = subscribeTopics.split(",");
        var adapter = new MqttPahoMessageDrivenChannelAdapter(
                brokerUrl, subscriberClientId, topics);
        adapter.setCompletionTimeout(5_000);
        adapter.setConverter(new DefaultPahoMessageConverter());
        adapter.setQos(1);
        adapter.setOutputChannel(mqttInboundChannel());
        return adapter;
    }

    @Bean
    @ServiceActivator(inputChannel = "mqttInboundChannel")
    public MessageHandler mqttMessageHandler(MqttSubscriberService mqttSubscriberService) {
        return message -> {
            String topic = (String) message.getHeaders()
                    .get(org.springframework.integration.mqtt.support.MqttHeaders.RECEIVED_TOPIC);
            String payload = (String) message.getPayload();
            mqttSubscriberService.handleMessage(topic, payload);
        };
    }
}
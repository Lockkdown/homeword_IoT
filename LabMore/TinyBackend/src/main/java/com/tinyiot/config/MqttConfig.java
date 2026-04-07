package com.tinyiot.config;

import com.tinyiot.service.MqttTelemetryService;
import lombok.RequiredArgsConstructor;
import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.integration.annotation.ServiceActivator;
import org.springframework.integration.channel.DirectChannel;
import org.springframework.integration.core.MessageProducer;
import org.springframework.integration.mqtt.core.DefaultMqttPahoClientFactory;
import org.springframework.integration.mqtt.inbound.MqttPahoMessageDrivenChannelAdapter;
import org.springframework.integration.mqtt.outbound.MqttPahoMessageHandler;
import org.springframework.integration.mqtt.support.DefaultPahoMessageConverter;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.MessageHandler;

@Configuration
@RequiredArgsConstructor
@org.springframework.integration.config.EnableIntegration
public class MqttConfig {

    private final MqttTelemetryService mqttTelemetryService;

    @Value("${mqtt.broker-url}")
    private String brokerUrl;

    @Value("${mqtt.username:}")
    private String mqttUsername;

    @Value("${mqtt.password:}")
    private String mqttPassword;

    @Bean
    public DefaultMqttPahoClientFactory mqttClientFactory() {
        DefaultMqttPahoClientFactory factory = new DefaultMqttPahoClientFactory();
        MqttConnectOptions options = new MqttConnectOptions();
        options.setServerURIs(new String[]{brokerUrl});
        options.setAutomaticReconnect(true);
        options.setCleanSession(true);
        if (mqttUsername != null && !mqttUsername.isBlank()) {
            options.setUserName(mqttUsername);
            options.setPassword(mqttPassword != null ? mqttPassword.toCharArray() : new char[0]);
        }
        factory.setConnectionOptions(options);
        return factory;
    }

    @Bean
    public MessageChannel mqttInboundChannel() {
        return new DirectChannel();
    }

    @Bean
    public MessageChannel mqttOutboundChannel() {
        return new DirectChannel();
    }

    @Bean
    public MessageProducer mqttInbound(
            DefaultMqttPahoClientFactory mqttClientFactory,
            @Qualifier("mqttInboundChannel") MessageChannel mqttInboundChannel
    ) {
        MqttPahoMessageDrivenChannelAdapter adapter = new MqttPahoMessageDrivenChannelAdapter(
                "tiny-backend-inbound",
                mqttClientFactory,
                MqttTelemetryService.T_RELAY_STATE,
                MqttTelemetryService.T_V,
                MqttTelemetryService.T_A,
                MqttTelemetryService.T_W,
                MqttTelemetryService.T_E,
                MqttTelemetryService.T_F,
                MqttTelemetryService.T_PF
        );
        adapter.setQos(1, 1, 1, 1, 1, 1, 1);
        adapter.setOutputChannel(mqttInboundChannel);
        adapter.setCompletionTimeout(5000);
        adapter.setConverter(new DefaultPahoMessageConverter());
        return adapter;
    }

    @Bean
    @ServiceActivator(inputChannel = "mqttInboundChannel")
    public MessageHandler mqttInboundHandler() {
        return message -> {
            Object topicObj = message.getHeaders().get(org.springframework.integration.mqtt.support.MqttHeaders.RECEIVED_TOPIC);
            String topic = topicObj != null ? topicObj.toString() : null;
            Object payload = message.getPayload();
            String body = payload != null ? payload.toString() : "";
            mqttTelemetryService.handleIncoming(topic, body);
        };
    }

    @Bean
    @ServiceActivator(inputChannel = "mqttOutboundChannel")
    public MessageHandler mqttOutboundHandler(DefaultMqttPahoClientFactory mqttClientFactory) {
        MqttPahoMessageHandler handler = new MqttPahoMessageHandler("tiny-backend-outbound", mqttClientFactory);
        handler.setAsync(true);
        return handler;
    }
}

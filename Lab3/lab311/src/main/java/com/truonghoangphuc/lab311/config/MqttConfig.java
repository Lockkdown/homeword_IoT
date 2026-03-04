package com.truonghoangphuc.lab311.config;

import com.truonghoangphuc.lab311.model.Telemetry;
import com.truonghoangphuc.lab311.repository.TelemetryRepository;
import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.integration.annotation.ServiceActivator;
import org.springframework.integration.channel.DirectChannel;
import org.springframework.integration.mqtt.core.DefaultMqttPahoClientFactory;
import org.springframework.integration.mqtt.core.MqttPahoClientFactory;
import org.springframework.integration.mqtt.inbound.MqttPahoMessageDrivenChannelAdapter;
import org.springframework.integration.mqtt.outbound.MqttPahoMessageHandler;
import org.springframework.integration.mqtt.support.DefaultPahoMessageConverter;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.MessageHandler;

@Configuration
public class MqttConfig {

    @Value("${mqtt.broker.url:tcp://localhost:1883}")
    private String brokerUrl;

    @Value("${mqtt.client.id:lab311-client}")
    private String clientId;

    @Autowired
    private TelemetryRepository telemetryRepository;

    @Bean
    public MqttPahoClientFactory mqttClientFactory() {
        DefaultMqttPahoClientFactory factory = new DefaultMqttPahoClientFactory();
        MqttConnectOptions options = new MqttConnectOptions();
        options.setServerURIs(new String[] { brokerUrl });
        factory.setConnectionOptions(options);
        return factory;
    }

    @Bean
    public MessageChannel mqttInputChannel() {
        return new DirectChannel();
    }

    @Bean
    public MessageChannel mqttOutboundChannel() {
        return new DirectChannel();
    }

    @Bean
    public MqttPahoMessageDrivenChannelAdapter inbound() {
        MqttPahoMessageDrivenChannelAdapter adapter = new MqttPahoMessageDrivenChannelAdapter(
                clientId + "_in",
                mqttClientFactory(),
                "/devices/+/telemetry");
        adapter.setCompletionTimeout(5000);
        adapter.setConverter(new DefaultPahoMessageConverter());
        adapter.setQos(1);
        adapter.setOutputChannel(mqttInputChannel());
        return adapter;
    }

    @Bean
    @ServiceActivator(inputChannel = "mqttInputChannel")
    public MessageHandler handler() {
        return message -> {
            System.out.println("Received MQTT message: " + message.getPayload());
            Telemetry telemetry = new Telemetry();
            telemetry.setPayload(message.getPayload().toString());

            String topic = (String) message.getHeaders().get("mqtt_receivedTopic");
            telemetry.setDeviceId(parseDeviceIdFromTopic(topic));

            telemetryRepository.save(telemetry);
        };
    }

    @Bean
    @ServiceActivator(inputChannel = "mqttOutboundChannel")
    public MessageHandler mqttOutbound() {
        MqttPahoMessageHandler messageHandler = new MqttPahoMessageHandler(clientId + "_out", mqttClientFactory());
        messageHandler.setAsync(true);
        messageHandler.setDefaultTopic("/devices/response");
        return messageHandler;
    }

    private Long parseDeviceIdFromTopic(String topic) {
        try {
            if (topic != null) {
                String[] parts = topic.split("/");
                // pattern: ["", "devices", "{id}", "telemetry"]
                if (parts.length >= 3) {
                    return Long.parseLong(parts[2]);
                }
            }
        } catch (NumberFormatException e) {
            System.err.println("Cannot parse deviceId from topic: " + topic);
        }
        return 0L;
    }
}

package com.tinyiot.service;

import lombok.RequiredArgsConstructor;
import org.springframework.integration.mqtt.support.MqttHeaders;
import org.springframework.integration.support.MessageBuilder;
import org.springframework.messaging.MessageChannel;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MqttOutboundService {

    public static final String TOPIC_RELAY_COMMAND = "tiny/relay/command";
    public static final String TOPIC_LED_COMMAND = "tiny/led/command";

    private final MessageChannel mqttOutboundChannel;

    public void publishRelayCommand(String command) {
        send(TOPIC_RELAY_COMMAND, command);
    }

    public void publishLedCommand(String command) {
        send(TOPIC_LED_COMMAND, command);
    }

    private void send(String topic, String payload) {
        mqttOutboundChannel.send(MessageBuilder.withPayload(payload)
                .setHeader(MqttHeaders.TOPIC, topic)
                .setHeader(MqttHeaders.QOS, 1)
                .build());
    }
}

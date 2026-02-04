package com.truonghoangphuc.lab307.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.integration.mqtt.support.MqttHeaders;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.support.MessageBuilder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
public class MqttPublisherService {
	private final MessageChannel mqttOutboundChannel;
	private final String defaultTopic;

	public MqttPublisherService(
			MessageChannel mqttOutboundChannel,
			@Value("${mqtt.topic:/test/topic}") String defaultTopic) {
		this.mqttOutboundChannel = mqttOutboundChannel;
		this.defaultTopic = defaultTopic;
	}

    public void publish(String message) {
		if (!StringUtils.hasText(message)) {
			throw new IllegalArgumentException("message must not be blank");
		}
        mqttOutboundChannel.send(
            MessageBuilder.withPayload(message)
                .setHeader(MqttHeaders.TOPIC, defaultTopic)
                .build()
        );
    }
}

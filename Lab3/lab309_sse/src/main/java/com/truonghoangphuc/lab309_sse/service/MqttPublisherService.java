package com.truonghoangphuc.lab309_sse.service;

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
		publish(defaultTopic, message);
	}

	public void publish(String topic, String message) {
		if (!StringUtils.hasText(topic)) {
			throw new IllegalArgumentException("topic must not be blank");
		}
		if (!StringUtils.hasText(message)) {
			throw new IllegalArgumentException("message must not be blank");
		}
		mqttOutboundChannel.send(
				MessageBuilder.withPayload(message)
						.setHeader(MqttHeaders.TOPIC, topic)
						.build());
	}
}

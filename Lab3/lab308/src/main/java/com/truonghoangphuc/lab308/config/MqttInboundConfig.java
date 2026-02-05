package com.truonghoangphuc.lab308.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.integration.annotation.ServiceActivator;
import org.springframework.integration.channel.DirectChannel;
import org.springframework.integration.mqtt.core.DefaultMqttPahoClientFactory;
import org.springframework.integration.mqtt.inbound.MqttPahoMessageDrivenChannelAdapter;
import org.springframework.integration.mqtt.support.DefaultPahoMessageConverter;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.MessageHandler;

import com.truonghoangphuc.lab308.service.WebSocketBroadcastService;

@Configuration
public class MqttInboundConfig {
	@Value("${mqtt.client-id:lab308}")
	private String clientId;

	@Value("${mqtt.topic:/test/temp}")
	private String topic;

	@Bean
	public MessageChannel mqttInboundChannel() {
		return new DirectChannel();
	}

	@Bean
	public MqttPahoMessageDrivenChannelAdapter mqttInboundAdapter(DefaultMqttPahoClientFactory mqttClientFactory,
			MessageChannel mqttInboundChannel) {
		var adapter = new MqttPahoMessageDrivenChannelAdapter(
				clientId + "-inbound",
				mqttClientFactory,
				topic);
		adapter.setCompletionTimeout(10_000);
		adapter.setConverter(new DefaultPahoMessageConverter());
		adapter.setQos(0);
		adapter.setOutputChannel(mqttInboundChannel);
		return adapter;
	}

	@Bean
	@ServiceActivator(inputChannel = "mqttInboundChannel")
	public MessageHandler mqttInboundHandler(WebSocketBroadcastService broadcastService) {
		return message -> {
			Object payload = message.getPayload();
			broadcastService.broadcastText(payload == null ? "" : payload.toString());
		};
	}
}

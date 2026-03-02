package com.truonghoangphuc.lab309.controller;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.truonghoangphuc.lab309.entity.MqttMessage;
import com.truonghoangphuc.lab309.repository.MqttMessageRepository;
import com.truonghoangphuc.lab309.service.MqttPublisherService;

@RestController
@RequestMapping("/api/mqtt")
public class MqttController {
	private static final Logger logger = LoggerFactory.getLogger(MqttController.class);

	private final MqttPublisherService mqttPublisherService;
	private final MqttMessageRepository mqttMessageRepository;

	public MqttController(MqttPublisherService mqttPublisherService,
			MqttMessageRepository mqttMessageRepository) {
		this.mqttPublisherService = mqttPublisherService;
		this.mqttMessageRepository = mqttMessageRepository;
	}

	public static final class PublishRequest {
		private String topic;
		private String message;

		public String getTopic() {
			return topic;
		}

		public void setTopic(String topic) {
			this.topic = topic;
		}

		public String getMessage() {
			return message;
		}

		public void setMessage(String message) {
			this.message = message;
		}
	}

	@PostMapping("/publish")
	public ResponseEntity<String> publish(@RequestBody(required = false) PublishRequest request) {
		if (request == null) {
			return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("request body is required");
		}
		if (!StringUtils.hasText(request.getMessage())) {
			return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("message must not be blank");
		}

		try {
			if (StringUtils.hasText(request.getTopic())) {
				mqttPublisherService.publish(request.getTopic(), request.getMessage());
			} else {
				mqttPublisherService.publish(request.getMessage());
			}
			return ResponseEntity.ok("Message published!");
		} catch (IllegalArgumentException ex) {
			return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(ex.getMessage());
		} catch (Exception ex) {
			logger.error("Failed to publish MQTT message. topic='{}'", request.getTopic(), ex);
			var message = ex.getMessage();
			var detail = StringUtils.hasText(message) ? message : ex.getClass().getName();
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
					.body("Failed to publish message: " + detail);
		}
	}

	@GetMapping("/messages")
	public ResponseEntity<List<MqttMessage>> getMessages() {
		return ResponseEntity.ok(mqttMessageRepository.findAllByOrderByPublishedAtDesc());
	}
}

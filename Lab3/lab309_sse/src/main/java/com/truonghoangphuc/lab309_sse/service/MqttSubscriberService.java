package com.truonghoangphuc.lab309_sse.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

/**
 * Nhận MQTT messages từ MqttConfig.mqttMessageHandler()
 * và forward tới SseEmitterService để broadcast ra SSE clients.
 */
@Service
public class MqttSubscriberService {

    private static final Logger logger = LoggerFactory.getLogger(MqttSubscriberService.class);

    private final SseEmitterService sseEmitterService;

    public MqttSubscriberService(SseEmitterService sseEmitterService) {
        this.sseEmitterService = sseEmitterService;
    }

    public void handleMessage(String topic, String payload) {
        logger.info("MQTT message received | topic={} | payload={}", topic, payload);
        sseEmitterService.broadcast(topic, payload);
    }
}

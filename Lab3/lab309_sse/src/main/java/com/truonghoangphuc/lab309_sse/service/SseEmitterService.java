package com.truonghoangphuc.lab309_sse.service;

import java.util.concurrent.CopyOnWriteArrayList;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

/**
 * Quản lý danh sách SSE client đang kết nối.
 * Khi có MQTT message mới, broadcast tới tất cả client.
 */
@Service
public class SseEmitterService {

    private static final Logger logger = LoggerFactory.getLogger(SseEmitterService.class);
    private static final long SSE_TIMEOUT = 5 * 60 * 1000L; // 5 phút

    // Thread-safe vì nhiều request có thể subscribe/unsubscribe đồng thời
    private final CopyOnWriteArrayList<SseEmitter> emitters = new CopyOnWriteArrayList<>();

    /**
     * Tạo SseEmitter mới cho client và đăng ký callbacks cleanup.
     */
    public SseEmitter subscribe() {
        SseEmitter emitter = new SseEmitter(SSE_TIMEOUT);

        emitter.onCompletion(() -> {
            emitters.remove(emitter);
            logger.debug("SSE client disconnected. Active clients: {}", emitters.size());
        });
        emitter.onTimeout(() -> {
            emitter.complete();
            emitters.remove(emitter);
            logger.debug("SSE client timed out. Active clients: {}", emitters.size());
        });
        emitter.onError(ex -> {
            emitters.remove(emitter);
            logger.debug("SSE client error: {}. Active clients: {}", ex.getMessage(), emitters.size());
        });

        emitters.add(emitter);
        logger.info("New SSE client subscribed. Active clients: {}", emitters.size());
        return emitter;
    }

    /**
     * Broadcast MQTT message tới tất cả SSE client đang kết nối.
     */
    public void broadcast(String topic, String payload) {
        String json = String.format("{\"topic\":\"%s\",\"payload\":\"%s\"}",
                topic, payload.replace("\"", "\\\""));

        for (SseEmitter emitter : emitters) {
            try {
                emitter.send(SseEmitter.event()
                        .name("mqtt-message")
                        .data(json));
            } catch (Exception ex) {
                emitters.remove(emitter);
                logger.warn("Failed to send SSE, removed client. Reason: {}", ex.getMessage());
            }
        }
        logger.info("Broadcasted to {} SSE clients | topic={} | payload={}", emitters.size(), topic, payload);
    }
}

package com.truonghoangphuc.lab309_sse.controller;

import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import com.truonghoangphuc.lab309_sse.service.SseEmitterService;

@RestController
@RequestMapping("/api/sse")
public class SseController {

    private final SseEmitterService sseEmitterService;

    public SseController(SseEmitterService sseEmitterService) {
        this.sseEmitterService = sseEmitterService;
    }

    /**
     * Client (Postman/browser) gọi endpoint này để subscribe SSE stream.
     * Kết nối sẽ được giữ mở; mỗi khi có MQTT message sẽ nhận được event ngay lập
     * tức.
     */
    @GetMapping(value = "/subscribe", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter subscribe() {
        return sseEmitterService.subscribe();
    }
}

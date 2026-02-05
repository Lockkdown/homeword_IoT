package com.truonghoangphuc.lab308.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;

import com.truonghoangphuc.lab308.websocket.TempWebSocketHandler;

@Configuration
@EnableWebSocket
public class WebSocketConfig implements WebSocketConfigurer {
	private final TempWebSocketHandler tempWebSocketHandler;

	public WebSocketConfig(TempWebSocketHandler tempWebSocketHandler) {
		this.tempWebSocketHandler = tempWebSocketHandler;
	}

	@Override
	public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
		registry.addHandler(tempWebSocketHandler, "/ws").setAllowedOrigins("*");
		registry.addHandler(tempWebSocketHandler, "/").setAllowedOrigins("*");
	}
}

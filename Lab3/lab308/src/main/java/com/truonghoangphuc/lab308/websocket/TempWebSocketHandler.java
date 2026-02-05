package com.truonghoangphuc.lab308.websocket;

import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import com.truonghoangphuc.lab308.service.WebSocketBroadcastService;

@Component
public class TempWebSocketHandler extends TextWebSocketHandler {
	private final WebSocketBroadcastService broadcastService;

	public TempWebSocketHandler(WebSocketBroadcastService broadcastService) {
		this.broadcastService = broadcastService;
	}

	@Override
	public void afterConnectionEstablished(WebSocketSession session) throws Exception {
		broadcastService.registerSession(session);
		session.sendMessage(new TextMessage("connected"));
	}

	@Override
	public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
		broadcastService.unregisterSession(session);
	}
}

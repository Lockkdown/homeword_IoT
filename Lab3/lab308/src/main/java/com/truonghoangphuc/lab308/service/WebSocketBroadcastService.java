package com.truonghoangphuc.lab308.service;

import java.io.IOException;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.stereotype.Service;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;

@Service
public class WebSocketBroadcastService {
	private final Set<WebSocketSession> sessions = ConcurrentHashMap.newKeySet();

	public void registerSession(WebSocketSession session) {
		if (session != null) {
			sessions.add(session);
		}
	}

	public void unregisterSession(WebSocketSession session) {
		if (session != null) {
			sessions.remove(session);
		}
	}

	public void broadcastText(String payload) {
		if (payload == null) {
			return;
		}

		var message = new TextMessage(payload);
		for (var session : sessions) {
			if (session == null || !session.isOpen()) {
				continue;
			}
			try {
				session.sendMessage(message);
			} catch (IOException ex) {
				sessions.remove(session);
			}
		}
	}
}

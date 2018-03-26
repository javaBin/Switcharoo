package no.javazone.switcharoo.api;

import io.vavr.control.Try;
import no.javazone.switcharoo.api.socketio.ClientType;
import no.javazone.switcharoo.api.socketio.WSSession;
import no.javazone.switcharoo.api.socketio.WSSessions;
import org.eclipse.jetty.websocket.api.Session;
import org.eclipse.jetty.websocket.api.annotations.OnWebSocketClose;
import org.eclipse.jetty.websocket.api.annotations.OnWebSocketConnect;
import org.eclipse.jetty.websocket.api.annotations.OnWebSocketMessage;
import org.eclipse.jetty.websocket.api.annotations.WebSocket;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static io.vavr.API.*;

@WebSocket
public class Ws {

    private static Logger LOG = LoggerFactory.getLogger(Ws.class);
    private final WSSessions sessions;

    public Ws(WSSessions sessions) {
        this.sessions = sessions;
    }

    @SuppressWarnings("unused")
    @OnWebSocketConnect
    public void connect(Session session) {
        LOG.info("WS connection");
        WSSession newSession = sessions.create(session);
        Try.run(() -> session.getRemote().sendString("WELCOME:"))
            .onFailure(e -> {
                LOG.warn("Could not register newly connected WS client, closing socket...");
                Try.run(() -> session.close());
            });
    }

    @SuppressWarnings("unused")
    @OnWebSocketMessage
    public void onMessage(Session session, String rawMessage) {
        String command = getCommand(rawMessage);
        String message = getMessage(rawMessage);

        Match(command).of(
            Case($("REGISTER"), () -> run(() -> register(session, message)) ),
            Case($(), () -> run(() -> unknownCommand(rawMessage)))
        );

        int clientCount = sessions.of(ClientType.PUBLIC).size();
        sessions.of(ClientType.ADMIN)
            .forEach((s, ws) -> Try.run(() -> s.getRemote().sendString("CLIENTCOUNT:" + clientCount)));
    }

    @SuppressWarnings("unused")
    @OnWebSocketClose
    public void close(Session session, int statusCode, String reason) {
        sessions.remove(session);
        int clientCount = sessions.of(ClientType.PUBLIC).size();
        sessions.of(ClientType.ADMIN)
            .forEach((s, ws) -> Try.run(() -> s.getRemote().sendString("CLIENTCOUNT:" + clientCount)));
    }

    private void register(Session session, String clientType) {
        ClientType type = Try.of(() -> ClientType.valueOf(clientType))
            .getOrElseGet(e -> ClientType.UNKNOWN);

        sessions.get(session).forEach(wsSession -> wsSession.setClientType(type));
    }

    private void unknownCommand(String command) {
        LOG.warn("Unknown command received: {}", command);
    }

    private String getCommand(String rawMessage) {
        String[] parts = rawMessage.split(":");
        if (parts.length == 2) {
            return parts[0];
        } else {
            return "";
        }
    }

    private String getMessage(String rawMessage) {
        String[] parts = rawMessage.split(":");
        if (parts.length == 2) {
            return parts[1];
        } else {
            return "";
        }
    }
}

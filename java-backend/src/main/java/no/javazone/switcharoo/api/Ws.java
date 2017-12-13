package no.javazone.switcharoo.api;

import io.vavr.collection.HashMap;
import io.vavr.collection.List;
import io.vavr.collection.Map;
import io.vavr.collection.Queue;
import io.vavr.control.Try;
import no.javazone.switcharoo.api.socketio.SocketIOSession;
import no.javazone.switcharoo.api.socketio.SocketIOSessions;
import org.eclipse.jetty.websocket.api.Session;
import org.eclipse.jetty.websocket.api.annotations.OnWebSocketClose;
import org.eclipse.jetty.websocket.api.annotations.OnWebSocketConnect;
import org.eclipse.jetty.websocket.api.annotations.OnWebSocketMessage;
import org.eclipse.jetty.websocket.api.annotations.WebSocket;
import org.eclipse.jetty.websocket.common.WebSocketSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.Arrays;

@WebSocket
public class Ws {

    private static Logger LOG = LoggerFactory.getLogger(Ws.class);
    private final SocketIOSessions sessions;

    public Ws(SocketIOSessions sessions) {
        this.sessions = sessions;
    }

    @OnWebSocketConnect
    public void connect(Session session) {
        WebSocketSession webSocketSession = (WebSocketSession)session;
        if (webSocketSession == null) {
            LOG.info("Session was not WebSocketSession");
            return;
        }
        Map<String, String> query = query(webSocketSession.getRequestURI().getQuery());
        SocketIOSession s = query.get("sid")
            .flatMap(sessions::get)
            .getOrElse(() -> {
                LOG.warn("Could not find session for sid, ignoring");
                return null;
            });

        if (s != null) {
            s.setWebsocketSession(session);
        }
    }

    private static final String PING = "2";
    private static final String PONG = "3";
    private static final String UPGRADE = "5";

    @OnWebSocketMessage
    public void onMessage(Session session, String message) throws IOException {
        WebSocketSession webSocketSession = (WebSocketSession)session;
        LOG.info("Message received: '{}'", message);
        if ("2probe".equals(message)) {
            webSocketSession.getRemote().sendString("3probe");
        } else if (PING.equals(message)) {
            webSocketSession.getRemote().sendString(PONG);
        } else if (UPGRADE.equals(message)) {
            Map<String, String> query = query(webSocketSession.getRequestURI().getQuery());

            String namespace = query.get("sid")
                .flatMap(sessions::get)
                .map(s -> s.getNamespace())
                .getOrElse("");

            if ("/admin".equals(namespace)) {
                session.getRemote().sendString(clientCountMessage());
            } else if ("/users".equals(namespace)) {
                sessions.of("/admin").forEach(s -> {
                    Try.run(() -> {
                        s.getWebsocketSession().getRemote().sendString(clientCountMessage());
                    });
                });
            } else {
                LOG.warn("Unknown namespace {}, ignoring", namespace);
            }
        }
    }

    @OnWebSocketClose
    public void close(Session session, int statusCode, String reason) {
        WebSocketSession webSocketSession = (WebSocketSession)session;
        if (webSocketSession == null) {
            LOG.info("SocketIOSession was not WebSocketSession");
            return;
        }

        Map<String, String> query = query(webSocketSession.getRequestURI().getQuery());
        String sid = query.get("sid").getOrElse("");
        LOG.info("Removing user with session id '{}'", sid);
        sessions.remove(sid);
        sessions.of("/admin").forEach(s -> {
            Try.run(() -> {
                s.getWebsocketSession().getRemote().sendString(clientCountMessage());
            });
        });

        //if (path == "/admin") {
            //admins = admins.remove(session);
        //} else {
            //clients.remove(session);
            //updateAdmins(admins, clients);
        //}
    }

    private String clientCountMessage() {
        return String.format("42/admin,[\"event\", \"%s\"]", Integer.toString(sessions.of("/users").size()));
    }

    private void updateAdmin(final WebSocketSession admin, final Queue<WebSocketSession> clients) {
        Try.run(() -> admin.getRemote().sendString(String.valueOf(clients.size())))
            .onFailure(e -> LOG.error("Error while updating admin", e));
    }

    private void updateAdmins(final Queue<WebSocketSession> admins, final Queue<WebSocketSession> clients) {
        admins.forEach(admin -> updateAdmin(admin, clients));
    }

    private Map<String, String> query(String queryString) {
        return List.ofAll(Arrays.asList(queryString.split("&")))
            .foldLeft(HashMap.empty(), (map, cur) -> {
                String[] keyVal = cur.split("=");
                return map.put(keyVal[0], keyVal[1]);
            });
    }
}

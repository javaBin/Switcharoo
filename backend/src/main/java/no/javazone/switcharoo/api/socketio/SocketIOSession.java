package no.javazone.switcharoo.api.socketio;


import org.eclipse.jetty.websocket.api.Session;

import static no.javazone.switcharoo.api.socketio.ConnectionState.CONNECTING;

public class SocketIOSession {
    private ConnectionState connectionState;
    private String sessionId;
    private String namespace;
    private Session websocketSession;

    public SocketIOSession(String sessionId) {
        connectionState = CONNECTING;
        this.sessionId = sessionId;
    }

    public void setNamespace(String namespace) {
        this.namespace = namespace;
    }

    public String getNamespace() {
        return namespace;
    }

    public void setConnectionState(ConnectionState connectionState) {
        this.connectionState = connectionState;
    }

    public ConnectionState getConnectionState() {
        return connectionState;
    }

    public String getSessionId() {
        return sessionId;
    }

    public Session getWebsocketSession() {
        return websocketSession;
    }

    public void setWebsocketSession(Session websocketSession) {
        this.websocketSession = websocketSession;
    }

    @Override
    public String toString() {
        return "SocketIOSession{" +
            "sessionId='" + sessionId + '\'' +
            ", namespace='" + namespace + '\'' +
            '}';
    }
}

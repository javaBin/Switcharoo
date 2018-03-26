package no.javazone.switcharoo.api.socketio;

public class WSSession {
    private ClientType clientType;

    public WSSession() {
        clientType = ClientType.UNKNOWN;
    }

    public void setClientType(ClientType clientType) {
        this.clientType = clientType;
    }

    public ClientType getClientType() {
        return clientType;
    }

    @Override
    public String toString() {
        return "SocketIOSession{" +
            "clientType='" + clientType + '\'' +
            '}';
    }
}

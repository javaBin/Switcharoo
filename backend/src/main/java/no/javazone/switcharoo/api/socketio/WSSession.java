package no.javazone.switcharoo.api.socketio;

public class WSSession {
    private ClientType clientType;
    private String conference;

    public WSSession() {
        clientType = ClientType.UNKNOWN;
    }

    public void setClientType(ClientType clientType) {
        this.clientType = clientType;
    }

    public ClientType getClientType() {
        return clientType;
    }

    public String getConference() {
        return conference;
    }

    public void setConference(String conference) {
        this.conference = conference;
    }

    @Override
    public String toString() {
        return "WSSession{" +
            "clientType=" + clientType +
            ", conference=" + conference +
            '}';
    }
}

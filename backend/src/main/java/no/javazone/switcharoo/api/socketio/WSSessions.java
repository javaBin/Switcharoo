package no.javazone.switcharoo.api.socketio;

import io.vavr.collection.HashMap;
import io.vavr.collection.Map;
import io.vavr.control.Option;
import org.eclipse.jetty.websocket.api.Session;

public class WSSessions {

    private Map<Session, WSSession> sessions;

    public WSSessions() {
        sessions = HashMap.empty();
    }

    public Option<WSSession> get(Session session) {
        return sessions.get(session);
    }

    public WSSession create(Session session) {
        WSSession s = new WSSession();
        sessions = sessions.put(session, s);
        return s;
    }

    public Map<Session, WSSession> of(ClientType clientType) {
        return sessions.filter(s -> clientType.equals(s._2.getClientType()));
    }

    public void remove(Session session) {
        sessions = sessions.remove(session);
    }
}

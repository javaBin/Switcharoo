package no.javazone.switcharoo.api.socketio;

import io.vavr.collection.HashMap;
import io.vavr.collection.List;
import io.vavr.collection.Map;
import io.vavr.collection.Seq;
import io.vavr.control.Option;
import no.javazone.switcharoo.api.Ws;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Arrays;
import java.util.concurrent.ThreadLocalRandom;

public class SocketIOSessions {

    private static Logger LOG = LoggerFactory.getLogger(SocketIOSessions.class);

    private static final int SESSION_ID_LEN = 20;
    private static final char[] SYMBOLS;
    private Map<String, SocketIOSession> sessions;

    public SocketIOSessions() {
        sessions = HashMap.empty();
    }

    public Option<SocketIOSession> get(String sid) {
        return sessions.get(sid);
    }

    public SocketIOSession create() {
        SocketIOSession s = new SocketIOSession(generateSessionId());
        sessions = sessions.put(s.getSessionId(), s);
        return s;
    }

    public Seq<SocketIOSession> of(String namespace) {
        LOG.info("Sessions: {}", Arrays.toString(sessions.values().toJavaArray()));
        return sessions.values().filter(s -> namespace.equals(s.getNamespace()));
    }

    public void remove(String sid) {
        LOG.info("Removing session with session id '{}'", sid);
        sessions = sessions.remove(sid);
    }

    private String generateSessionId()
    {
        while(true)
        {
            StringBuilder sb = new StringBuilder(SESSION_ID_LEN);
            for (int i = 0; i < SESSION_ID_LEN; i++)
                sb.append(SYMBOLS[ThreadLocalRandom.current().nextInt(SYMBOLS.length)]);

            String id = sb.toString();
            if(sessions.get(id).isEmpty())
                return id;
        }
    }

    static
    {
        StringBuilder sb = new StringBuilder();
        for (char ch = 'A'; ch <= 'Z'; ch++)
            sb.append(ch);
        for (char ch = 'a'; ch <= 'z'; ch++)
            sb.append(ch);
        SYMBOLS = sb.toString().toCharArray();
    }
}

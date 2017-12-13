package no.javazone.switcharoo.api;

import com.google.gson.Gson;
import no.javazone.switcharoo.api.socketio.ConnectionState;
import no.javazone.switcharoo.api.socketio.SocketIOSession;
import no.javazone.switcharoo.api.socketio.SocketIOSessions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;

import static spark.Spark.*;

public class SocketIO implements HttpService {

    private final Logger LOG = LoggerFactory.getLogger(SocketIO.class);
    private final String socketIOJS;
    private final SocketIOSessions sessions;

    public SocketIO(SocketIOSessions sessions) {
        String content;
        ClassLoader classLoader = getClass().getClassLoader();
        File file = new File(classLoader.getResource("socket.io.js").getFile());
        try {
            content = new String(Files.readAllBytes(file.toPath()));
        } catch (IOException e) {
            content = null;
            LOG.error("Could not load socket.io.js content", e);
        }
        socketIOJS = content;
        this.sessions = sessions;
    }

    @Override
    public void register(Gson gson) {

        get("/socket.io/socket.io.js", (req, res) -> {
            res.type("application/javascript");
            if (socketIOJS == null) {
                res.status(404);
                return "";
            } else {
                return socketIOJS;
            }
        });

        get("/socket.io/*", (req, res) -> {
            if ("websocket".equals(req.queryParams("transport"))) {
                // Spark has trouble separating routes, so we must return null to get to the next route
                return null;
            }

            String sid = req.queryParams("sid");
            String response;
            if (sid == null) {
                SocketIOSession s = sessions.create();
                LOG.info("SID was empty, generating new SocketIOSession");
                sid = s.getSessionId();
                response = "0{\"sid\":\"" + sid + "\",\"upgrades\":[\"websocket\"],\"pingInterval\":25000,\"pingTimeout\":60000}";
            } else {
                response = sessions.get(sid)
                    .map(session -> {
                        if (session.getConnectionState() == ConnectionState.CONNECTING) {
                            return "40" + session.getNamespace();
                        } else {
                            return "6";
                        }
                    }).getOrElse(() -> "");
            }

            HttpServletResponse raw = res.raw();
            raw.setHeader("content-type", "application/octet-stream");
            Cookie cookie = new Cookie("io", sid);
            cookie.setHttpOnly(true);
            cookie.setPath("/");
            raw.addCookie(cookie);
            raw.setHeader("connection", "keep-alive");
            OutputStream os = raw.getOutputStream();
            os.write(0); //binary packet
            os.write(encodeLength(response.length() + 1)); // + 1 for packet type
            os.write(255);
            os.write(response.getBytes("UTF-8"));
            os.close();
            return "";
        });

        post("/socket.io/*", (req, res) -> {
            String body = req.body();
            String sid = req.queryParams("sid");
            String response = sessions.get(sid)
                .map(session -> {
                    String namespace = body.split(":")[1];
                    LOG.info("User registered on namespace '{}'", namespace.substring(2));
                    session.setNamespace(namespace.substring(2));
                    return "ok";
                }).getOrElse(() -> {
                    res.status(404);
                    return "";
                });
            return response;
        });

    }

    private static byte[] encodeLength(int len)
    {
        byte[] bytes = String.valueOf(len).getBytes();
        for(int i = 0; i < bytes.length; i++)
            bytes[i] -= '0';
        return bytes;
    }
}

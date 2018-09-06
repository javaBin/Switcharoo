package no.javazone.switcharoo.api;

import com.google.gson.Gson;
import no.javazone.switcharoo.Authentication;

import static spark.Spark.get;


public class Auth implements HttpService {

    private final Authentication auth;

    public Auth(Authentication auth) {
        this.auth = auth;
    }
    @Override
    public void register(Gson gson) {
        get("/auth/verify", (req, res) -> {
            if (auth.verify(req)) {
                res.status(200);
            } else {
                res.status(401);
            }

            return "";
        });
    }
}

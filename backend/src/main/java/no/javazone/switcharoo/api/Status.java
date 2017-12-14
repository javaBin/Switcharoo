package no.javazone.switcharoo.api;

import com.google.gson.Gson;
import no.javazone.switcharoo.dao.StatusDao;

import static spark.Spark.get;

public class Status implements HttpService {

    private final StatusDao status;

    public Status(StatusDao status) {
        this.status = status;
    }

    @Override
    public void register(Gson gson) {
        get("/status", (req, res) -> {
            if (status.isConnected()) {
                res.status(200);
            } else {
                res.status(500);
            }
            return "";
        });
    }
}

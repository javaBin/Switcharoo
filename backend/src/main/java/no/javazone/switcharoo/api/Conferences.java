package no.javazone.switcharoo.api;

import com.google.gson.Gson;
import no.javazone.switcharoo.Authentication;
import no.javazone.switcharoo.api.mapper.ConferenceMapper;
import no.javazone.switcharoo.api.model.Conference;
import no.javazone.switcharoo.dao.ConferenceDao;
import no.javazone.switcharoo.exception.BadRequestException;
import no.javazone.switcharoo.exception.NotFoundException;

import static no.javazone.switcharoo.Util.parseLong;
import static no.javazone.switcharoo.api.verifier.ConferenceVerifier.verify;
import static spark.Spark.*;


public class Conferences implements HttpService {

    private final ConferenceDao conferences;
    private final Authentication auth;

    public Conferences(ConferenceDao conferences, Authentication auth) {

        this.conferences = conferences;
        this.auth = auth;
    }

    @Override
    public void register(Gson gson) {
        path("/", () -> {
            get("/conferences", (req, res) -> gson.toJson(conferences.list().map(ConferenceMapper::fromDb).toJavaList()));

            get("/conferences/:id", (req, res) ->
                gson.toJson(parseLong(req.params(":id"))
                    .flatMap(conferences::get)
                    .map(ConferenceMapper::fromDb)
                    .getOrElseThrow(NotFoundException::new))
            );

            post("/conferences", (req, res) -> gson.toJson(verify(gson.fromJson(req.body(), Conference.class))
                    .map(ConferenceMapper::toDb)
                    .flatMap(conferences::create)
                    .map(ConferenceMapper::fromDb)
                    .getOrElseThrow(BadRequestException::new))
            );

            put("/conferences/:id", (req, res) -> gson.toJson(verify(gson.fromJson(req.body(), Conference.class))
                    .map(ConferenceMapper::toDb)
                    .flatMap(c -> parseLong(req.params(":id")).map(i -> c.withId(i)))
                    .flatMap(conferences::update)
                    .map(ConferenceMapper::fromDb)
                    .getOrElseThrow(BadRequestException::new))
            );

            delete("/conferences/:id", (req, res) -> gson.toJson(parseLong(req.params(":id"))
                    .flatMap(conferences::delete)
                    .map(deleted -> {
                        res.status(deleted ? 200 : 404);
                        return "";
                    })
                    .getOrElseThrow(BadRequestException::new))
            );

            before("/conferences", (req, res) -> { if (!auth.verify(req)) halt(401); });
            before("/conferences/*", (req, res) -> { if (!auth.verify(req)) halt(401); });
            after("/conferences", (req, res) -> res.type("application/json"));
            after("/conferences/*", (req, res) -> res.type("application/json"));
        });

    }
}

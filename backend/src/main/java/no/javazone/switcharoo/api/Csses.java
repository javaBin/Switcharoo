package no.javazone.switcharoo.api;

import com.google.gson.Gson;
import io.vavr.collection.List;
import io.vavr.control.Either;
import no.javazone.switcharoo.Application;
import no.javazone.switcharoo.Authentication;
import no.javazone.switcharoo.api.mapper.CssMapper;
import no.javazone.switcharoo.api.model.Css;
import no.javazone.switcharoo.dao.ConferenceDao;
import no.javazone.switcharoo.dao.CssDao;
import no.javazone.switcharoo.exception.BadRequestException;
import no.javazone.switcharoo.exception.NotFoundException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static no.javazone.switcharoo.Util.parseLong;
import static no.javazone.switcharoo.api.verifier.CssVerifier.verify;
import static spark.Spark.*;

public class Csses implements HttpService {

    static Logger LOG = LoggerFactory.getLogger(Csses.class);
    private final CssDao css;
    private final ConferenceDao conferences;
    private final Authentication auth;

    public Csses(CssDao css, ConferenceDao conferences, Authentication auth) {
        this.css = css;
        this.conferences = conferences;
        this.auth = auth;
    }

    @Override
    public void register(Gson gson) {
        path("/conferences/:conference", () -> {
            get("/css", (req, res) -> gson.toJson(css.list(req.attribute("conference")).map(CssMapper::fromDb)));

            get("/css/:id",
                (req, res) -> gson.toJson(parseLong(req.params(":id"))
                    .flatMap(id -> css.get(id, req.attribute("conference")))
                    .map(CssMapper::fromDb)
                    .getOrElseThrow(NotFoundException::new))
            );

            post("/css",
                (req, res) -> gson.toJson(verify(gson.fromJson(req.body(), Css.class))
                    .map(CssMapper::toDb)
                    .flatMap(c -> css.create(c, req.attribute("conference")))
                    .map(CssMapper::fromDb)
                    .getOrElseThrow(BadRequestException::new))
            );

            put("/css/:id",
                (req, res) -> gson.toJson(verify(gson.fromJson(req.body(), Css.class))
                    .map(CssMapper::toDb)
                    .flatMap(c -> parseLong(req.params(":id")).map(id -> c.withId(id)))
                    .flatMap(c -> css.update(c, req.attribute("conference")))
                    .map(CssMapper::fromDb)
                    .getOrElseThrow(BadRequestException::new))
            );

            put("/css",
                (req, res) -> gson.toJson(List.of(gson.fromJson(req.body(), Css[].class))
                    .map(CssMapper::toDb)
                    .map(c -> {
                        Either<String, no.javazone.switcharoo.dao.model.Css> updated = css.update(c, req.attribute("conference"));
                        if (updated.isLeft()) {
                            return c;
                        } else {
                            return updated.get();
                        }
                    })
                    .map(CssMapper::fromDb))
            );

            delete("/css/:id",
                (req, res) -> gson.toJson(parseLong(req.params(":id"))
                    .flatMap(css::delete)
                    .map(deleted -> {
                        if (deleted) {
                            res.status(200);
                        } else {
                            res.status(404);
                        }
                        return "";
                    })
                    .getOrElseThrow(BadRequestException::new))
            );

            before("/css", (req, res) -> { if(!auth.verify(req)) halt(401);});
            before("/css/*", (req, res) -> { if(!auth.verify(req)) halt(401);});
            after("/css", (req, res) -> res.type("application/json"));
            after("/css/*", (req, res) -> res.type("application/json"));
        });

        get("/custom.css/:conference", (req, res) -> {
            Application.setConference(req, conferences);
            res.type("text/css");
            return css.list(req.attribute("conference")).map(r -> String.format("%s { %s: %s; }", r.selector, r.property, r.value))
                    .foldLeft("", (prev, cur) -> String.format("%s\n%s", prev, cur));
        });

    }
}

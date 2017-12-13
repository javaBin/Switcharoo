package no.javazone.switcharoo.api;

import com.google.gson.Gson;
import io.vavr.collection.List;
import io.vavr.control.Either;
import no.javazone.switcharoo.api.mapper.CssMapper;
import no.javazone.switcharoo.api.model.Css;
import no.javazone.switcharoo.dao.CssDao;
import no.javazone.switcharoo.exception.BadRequestException;
import no.javazone.switcharoo.exception.NotFoundException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;

import static no.javazone.switcharoo.Util.parseLong;
import static no.javazone.switcharoo.api.verifier.CssVerifier.verify;
import static spark.Spark.*;

public class Csses implements HttpService {

    static Logger LOG = LoggerFactory.getLogger(Csses.class);
    private final CssDao css;

    public Csses(CssDao css) {
        this.css = css;
    }

    @Override
    public void register(Gson gson) {
        path("/", () -> {
            get("/css",
                (req, res) -> css.list().map(CssMapper::fromDb).toJavaList(),
                gson::toJson
            );

            get("/css/:id",
                (req, res) -> parseLong(req.params(":id"))
                    .flatMap(css::get)
                    .map(CssMapper::fromDb)
                    .getOrElseThrow(NotFoundException::new),
                gson::toJson
            );

            post("/css",
                (req, res) -> verify(gson.fromJson(req.body(), Css.class))
                    .map(CssMapper::toDb)
                    .flatMap(css::create)
                    .map(CssMapper::fromDb)
                    .getOrElseThrow(BadRequestException::new),
                gson::toJson
            );

            put("/css/:id",
                (req, res) -> verify(gson.fromJson(req.body(), Css.class))
                    .map(CssMapper::toDb)
                    .flatMap(c -> parseLong(req.params(":id")).map(id -> c.withId(id)))
                    .flatMap(css::update)
                    .map(CssMapper::fromDb)
                    .getOrElseThrow(BadRequestException::new),
                gson::toJson
            );

            put("/css",
                (req, res) -> List.of(gson.fromJson(req.body(), Css[].class))
                    .map(CssMapper::toDb)
                    .map(c -> {
                        Either<String, no.javazone.switcharoo.dao.model.Css> updated = css.update(c);
                        if (updated.isLeft()) {
                            return c;
                        } else {
                            return updated.get();
                        }
                    })
                    .map(CssMapper::fromDb)
                    .toJavaList(),
                gson::toJson
            );

            delete("/css/:id",
                (req, res) -> parseLong(req.params(":id"))
                    .flatMap(css::delete)
                    .map(deleted -> {
                        if (deleted) {
                            res.status(200);
                        } else {
                            res.status(404);
                        }
                        return "";
                    })
                    .getOrElseThrow(BadRequestException::new),
                gson::toJson
            );

            after("/css", (req, res) -> res.type("application/json"));
            after("/css/*", (req, res) -> res.type("application/json"));
        });

        get("/custom.css", (req, res) -> {
            res.type("text/css");
            return css.list().map(r -> String.format("%s { %s: %s; }", r.selector, r.property, r.value))
                    .foldLeft("", (prev, cur) -> String.format("%s\n%s", prev, cur));
        });

    }
}

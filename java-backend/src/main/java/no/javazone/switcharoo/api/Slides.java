package no.javazone.switcharoo.api;

import com.google.gson.Gson;
import no.javazone.switcharoo.Authentication;
import no.javazone.switcharoo.api.mapper.SlideMapper;
import no.javazone.switcharoo.api.model.Slide;
import no.javazone.switcharoo.dao.SlidesDao;
import no.javazone.switcharoo.exception.BadRequestException;
import no.javazone.switcharoo.exception.NotFoundException;

import static no.javazone.switcharoo.Util.*;
import static no.javazone.switcharoo.api.verifier.SlideVerifier.verify;
import static spark.Spark.*;

public class Slides implements HttpService {

    private final SlidesDao slides;
    private final Authentication auth;

    public Slides(SlidesDao slides, Authentication auth) {
        this.slides = slides;
        this.auth = auth;
    }

    @Override
    public void register(Gson gson) {
        path("/", () -> {
            get("/slides",
                (req, res) -> slides.list().map(SlideMapper::fromDb).toJavaList(), gson::toJson);

            get("/slides/:id",
                (req, res) -> parseLong(req.params(":id"))
                    .flatMap(id -> slides.get(id))
                    .map(SlideMapper::fromDb)
                    .getOrElseThrow(NotFoundException::new),
                gson::toJson
            );

            post("/slides",
                (req, res) -> verify(gson.fromJson(req.body(), Slide.class))
                    .map(SlideMapper::toDb)
                    .flatMap(slides::create)
                    .map(SlideMapper::fromDb)
                    .getOrElseThrow(BadRequestException::new),
                gson::toJson
            );

            put("/slides/:id",
                (req, res) -> verify(gson.fromJson(req.body(), Slide.class))
                    .map(SlideMapper::toDb)
                    .flatMap(s -> parseLong(req.params(":id")).map(id -> s.withId(id)))
                    .flatMap(slides::update)
                    .map(SlideMapper::fromDb)
                    .getOrElseThrow(BadRequestException::new),
                gson::toJson
            );

            delete("/slides/:id",
                (req, res) -> parseInt(req.params(":id"))
                    .flatMap(slides::delete)
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

            before("/slides", (req, res) -> { if (!auth.verify(req)) halt(401);});
            before("/slides/*", (req, res) -> { if (!auth.verify(req)) halt(401);});
            after("/slides", (req, res) -> res.type("application/json"));
            after("/slides/*", (req, res) -> res.type("application/json"));
        });

    }
}

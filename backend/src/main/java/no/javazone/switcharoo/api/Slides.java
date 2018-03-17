package no.javazone.switcharoo.api;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import io.vavr.collection.List;
import io.vavr.control.Try;
import no.javazone.switcharoo.Authentication;
import no.javazone.switcharoo.api.mapper.SlideMapper;
import no.javazone.switcharoo.api.model.Slide;
import no.javazone.switcharoo.api.verifier.SlideVerifier;
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
        path("/conferences/:conference", () -> {
            get("/slides",
                (req, res) -> gson.toJson(slides.list(req.attribute("conference")).map(SlideMapper::fromDb)));

            get("/slides/:id",
                (req, res) -> gson.toJson(parseLong(req.params(":id"))
                    .flatMap(id -> slides.get(id, req.attribute("conference")))
                    .map(SlideMapper::fromDb)
                    .getOrElseThrow(NotFoundException::new))
            );

            post("/slides",
                (req, res) -> gson.toJson(verify(gson.fromJson(req.body(), Slide.class))
                    .map(SlideMapper::toDb)
                    .flatMap(s -> slides.create(s, req.attribute("conference")))
                    .map(SlideMapper::fromDb)
                    .getOrElseThrow(BadRequestException::new))
            );

            put("/slides/:id",
                (req, res) -> gson.toJson(verify(gson.fromJson(req.body(), Slide.class))
                    .map(SlideMapper::toDb)
                    .flatMap(s -> parseLong(req.params(":id")).map(id -> s.withId(id)))
                    .flatMap(s -> slides.update(s, req.attribute("conference")))
                    .map(SlideMapper::fromDb)
                    .getOrElseThrow(BadRequestException::new))
            );

            delete("/slides/:id",
                (req, res) -> gson.toJson(parseInt(req.params(":id"))
                    .flatMap(slides::delete)
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

            put("/slides-indexes",
                (req, res) -> Try.of(() -> (List<Long>)gson.fromJson(req.body(), new TypeToken<List<Long>>(){}.getType()))
                    .toEither("Malformed JSON")
                    .flatMap(SlideVerifier::verify)
                    .flatMap(ids -> slides.updateIndexes(ids, req.attribute("conference")))
                    .map(updated -> {
                        if (updated) {
                            res.status(200);
                        } else {
                            res.status(400);
                        }
                        return "";
                    })
                .getOrElseThrow(BadRequestException::new)
            );

            before("/slides", (req, res) -> { if (!auth.verify(req)) halt(401);});
            before("/slides/*", (req, res) -> { if (!auth.verify(req)) halt(401);});
            after("/slides", (req, res) -> res.type("application/json"));
            after("/slides/*", (req, res) -> res.type("application/json"));
        });

    }
}

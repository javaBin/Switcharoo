package no.javazone.switcharoo.api;

import com.google.gson.Gson;
import io.vavr.collection.List;
import io.vavr.control.Either;
import no.javazone.switcharoo.Authentication;
import no.javazone.switcharoo.api.mapper.SettingMapper;
import no.javazone.switcharoo.api.model.Setting;
import no.javazone.switcharoo.dao.SettingsDao;
import no.javazone.switcharoo.exception.BadRequestException;
import no.javazone.switcharoo.exception.NotFoundException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static no.javazone.switcharoo.Util.*;
import static no.javazone.switcharoo.api.verifier.SettingVerifier.verify;
import static spark.Spark.*;

public class Settings implements HttpService {

    Logger LOG = LoggerFactory.getLogger(Settings.class);

    private final SettingsDao settings;
    private final Authentication auth;

    public Settings(SettingsDao settings, Authentication auth) {
        this.settings = settings;
        this.auth = auth;
    }

    @Override
    public void register(Gson gson) {
        path("/conferences/:conference", () -> {
            get("/settings", (req, res) -> gson.toJson(settings.list(req.attribute("conference")).map(SettingMapper::fromDb)));

            get("/settings/:id",
                (req, res) -> gson.toJson(parseInt(req.params(":id"))
                    .flatMap(id -> settings.get(id, req.attribute("conference")))
                    .map(SettingMapper::fromDb)
                    .getOrElseThrow(NotFoundException::new))
            );

            post("/settings",
                (req, res) -> gson.toJson(verify(gson.fromJson(req.body(), Setting.class))
                    .map(SettingMapper::toDb)
                    .flatMap(s -> settings.create(s, req.attribute("conference")))
                    .map(SettingMapper::fromDb)
                    .getOrElseThrow(BadRequestException::new))
            );

            put("/settings", (req, res) -> gson.toJson(List.of(gson.fromJson(req.body(), Setting[].class))
                .map(SettingMapper::toDb)
                .map(s -> {
                    Either<String, no.javazone.switcharoo.dao.model.Setting> updated = settings.update(s, req.attribute("conference"));
                    if (updated.isLeft()) {
                        return s;
                    } else {
                        return updated.get();
                    }
                }).map(SettingMapper::fromDb))
            );

            // TODO: Need to rewrite frontend and use this update function instead
            /*put("/settings/:id",
                (req, res) -> verify(gson.fromJson(req.body(), Setting.class))
                    .map(SettingMapper::toDb)
                    .flatMap(s -> parseLong(req.params(":id")).map(id -> s.withId(id)))
                    .flatMap(s -> settings.update(s))
                    .map(SettingMapper::fromDb)
                    .getOrElseThrow(BadRequestException::new),
                gson::toJson
            );*/

            delete("/settings/:id",
                (req, res) -> gson.toJson(parseInt(req.params(":id"))
                    .flatMap(id -> settings.delete(id))
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

            before("/settings", (req, res) -> { if (!auth.verify(req)) halt(401);});
            before("/settings/*", (req, res) -> { if (!auth.verify(req)) halt(401);});
            after("/settings", (req, res) -> res.type("application/json"));
            after("/settings/*", (req, res) -> res.type("application/json"));
        });
    }

}

package no.javazone.switcharoo.api;

import com.google.gson.Gson;
import io.vavr.collection.List;
import io.vavr.control.Either;
import no.javazone.switcharoo.api.mapper.CssMapper;
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

    final SettingsDao settings;

    public Settings(SettingsDao settings) {
        this.settings = settings;
    }

    @Override
    public void register(Gson gson) {
        path("/", () -> {
            get("/settings",
                (req, res) -> settings.list().map(SettingMapper::fromDb).toJavaList(),
                gson::toJson
            );

            get("/settings/:id",
                (req, res) -> parseInt(req.params(":id"))
                    .flatMap(id -> settings.get(id))
                    .map(SettingMapper::fromDb)
                    .getOrElseThrow(NotFoundException::new),
                gson::toJson
            );

            post("/settings",
                (req, res) -> verify(gson.fromJson(req.body(), Setting.class))
                    .map(SettingMapper::toDb)
                    .flatMap(s2 -> settings.create(s2))
                    .map(SettingMapper::fromDb)
                    .getOrElseThrow(BadRequestException::new),
                gson::toJson
            );

            put("/settings", (req, res) -> List.of(gson.fromJson(req.body(), Setting[].class))
                .map(SettingMapper::toDb)
                .map(s -> {
                    Either<String, no.javazone.switcharoo.dao.model.Setting> updated = settings.update(s);
                    if (updated.isLeft()) {
                        return s;
                    } else {
                        return updated.get();
                    }
                })
                .map(SettingMapper::fromDb)
                .toJavaList(),
                gson::toJson
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
                (req, res) -> parseInt(req.params(":id"))
                    .flatMap(id -> settings.delete(id))
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

            after("/settings", (req, res) -> res.type("application/json"));
            after("/settings/*", (req, res) -> res.type("application/json"));
        });
    }

}

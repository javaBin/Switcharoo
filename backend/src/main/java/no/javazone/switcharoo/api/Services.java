package no.javazone.switcharoo.api;

import com.google.gson.Gson;
import no.javazone.switcharoo.Authentication;
import no.javazone.switcharoo.api.mapper.ServiceMapper;
import no.javazone.switcharoo.api.model.Service;
import no.javazone.switcharoo.dao.ServiceDao;
import no.javazone.switcharoo.exception.BadRequestException;
import no.javazone.switcharoo.exception.NotFoundException;

import static no.javazone.switcharoo.Util.parseLong;
import static no.javazone.switcharoo.api.verifier.ServiceVerifier.verify;
import static spark.Spark.*;

public class Services implements HttpService {

    private final ServiceDao services;
    private final Authentication auth;

    public Services(ServiceDao services, Authentication auth) {
        this.services = services;
        this.auth = auth;
    }

    @Override
    public void register(Gson gson) {
        path("/", () -> {
            get("/services", (req, res) ->
                    services.list().map(ServiceMapper::fromDb).toJavaList(),
                gson::toJson
            );

            get("/services/:id", (req, res) ->
                    parseLong(req.params(":id"))
                        .flatMap(services::get)
                        .map(ServiceMapper::fromDb)
                        .getOrElseThrow(NotFoundException:: new),
                gson::toJson
            );

            post("/services", (req, res) ->
                    verify(gson.fromJson(req.body(), Service.class))
                        .map(ServiceMapper::toDb)
                        .flatMap(services::create)
                        .map(ServiceMapper::fromDb)
                        .getOrElseThrow(BadRequestException::new),
                gson::toJson
            );

            put("/services/:id", (req, res) ->
                parseLong(req.params(":id"))
                .flatMap(services::update)
                .map(ServiceMapper::fromDb)
                .getOrElseThrow(BadRequestException::new),
                gson::toJson
            );

            // TODO: Need to rewrite frontend and use this update function instead
            /*put("/services/:id", (req, res) ->
                    verify(gson.fromJson(req.body(), Service.class))
                        .map(ServiceMapper::toDb)
                        .flatMap(service -> parseLong(req.params(":id")).map(id -> service.withId(id)))
                        .flatMap(services::update)
                        .map(ServiceMapper::fromDb)
                        .getOrElseThrow(BadRequestException::new),
                gson::toJson
            );*/

            delete("/services/:id", (req, res) ->
                    parseLong(req.params(":id"))
                        .flatMap(services::delete)
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

            before("/services", (req, res) -> { if(!auth.verify(req)) halt(401);});
            before("/services/*", (req, res) -> { if(!auth.verify(req)) halt(401);});
            after("/services", (req, res) -> res.type("application/json"));
            after("/services/*", (req, res) -> res.type("application/json"));
        });
    }

}

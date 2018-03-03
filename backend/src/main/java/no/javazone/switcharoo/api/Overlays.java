package no.javazone.switcharoo.api;

import com.google.gson.Gson;
import no.javazone.switcharoo.api.mapper.OverlayMapper;
import no.javazone.switcharoo.api.model.Overlay;
import no.javazone.switcharoo.dao.OverlayDao;
import no.javazone.switcharoo.exception.BadRequestException;
import no.javazone.switcharoo.exception.NotFoundException;

import static no.javazone.switcharoo.api.verifier.OverlayValidator.validate;
import static spark.Spark.path;
import static spark.Spark.*;

public class Overlays implements HttpService {

    private final OverlayDao overlays;

    public Overlays(OverlayDao overlays) {
        this.overlays = overlays;
    }

    @Override
    public void register(Gson gson) {
        path("/conferences/:conference", () -> {
            get("/overlay", (req, res) -> gson.toJson(overlays.get(req.attribute("conference"))
                .map(OverlayMapper::fromDb)
                .getOrElseThrow(NotFoundException::new)
            ));

            put("/overlay", (req, res) -> gson.toJson(validate(gson.fromJson(req.body(), Overlay.class))
                .map(OverlayMapper::toDb)
                .flatMap(overlay -> overlays.update(overlay, req.attribute("conference")))
                .map(OverlayMapper::fromDb)
                .getOrElseThrow(BadRequestException::new)
            ));
        });
    }
}

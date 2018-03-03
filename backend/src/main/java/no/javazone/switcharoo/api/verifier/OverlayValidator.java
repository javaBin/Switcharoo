package no.javazone.switcharoo.api.verifier;

import io.vavr.control.Either;
import no.javazone.switcharoo.api.model.Overlay;

import static io.vavr.control.Either.left;
import static io.vavr.control.Either.right;

public class OverlayValidator {

    public static Either<String, Overlay> validate(Overlay overlay) {
        return overlay.enabled == null ? left("enabled cannot be null")
            : overlay.image == null ? left("image cannot be null")
            : overlay.placement == null ? left("placement cannot be null")
            : overlay.width == null ? left("width cannot be null")
            : overlay.height == null ? left("height cannot be null")
            : right(overlay);

    }
}

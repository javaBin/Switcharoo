package no.javazone.switcharoo.api.verifier;

import io.vavr.collection.List;
import io.vavr.control.Either;
import no.javazone.switcharoo.api.model.Css;

public class CssVerifier {

    public static Either<String, Css> verify(Css css) {
        return css.property == null ? Either.left("Property was empty")
            : css.selector == null ? Either.left("Selector was empty")
            : css.value == null ? Either.left("Value was empty")
            : css.type == null ? Either.left("Type was empty")
            : css.title == null ? Either.left("Title was empty")
            : Either.right(css);
    }

    public static List<Either<String, Css>> verify(Css[] css) {
        return List.of(css).map(CssVerifier::verify);
    }
}

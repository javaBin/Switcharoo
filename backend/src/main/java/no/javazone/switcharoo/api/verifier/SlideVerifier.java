package no.javazone.switcharoo.api.verifier;

import io.vavr.collection.List;
import io.vavr.control.Either;
import no.javazone.switcharoo.api.model.Slide;

public class SlideVerifier {

    public static Either<String, Slide> verify(Slide s) {
        return s.title == null ? Either.left("Title was empty")
            : s.body == null ? Either.left("Body was empty")
            : s.visible == null ? Either.left("Visible was empty")
            : s.type == null ? Either.left("Type was empty")
            : s.index == null ? Either.left("Index was empty")
            : s.name == null ? Either.left("Name was empty")
            : Either.right(s);
    }

    public static Either<String, List<Long>> verify(List<Long> ids) {
        return ids.filter(i -> i != null).length() != ids.length()
            ? Either.left("List contained null values") : Either.right(ids);
    }
}

package no.javazone.switcharoo.api.verifier;

import io.vavr.control.Either;
import no.javazone.switcharoo.api.model.Conference;

public class ConferenceVerifier {

    public static Either<String, Conference> verify(Conference conference) {
        return conference.name == null ? Either.left("Name was empty") : Either.right(conference);
    }
}

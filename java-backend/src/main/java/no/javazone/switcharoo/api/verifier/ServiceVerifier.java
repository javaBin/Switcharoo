package no.javazone.switcharoo.api.verifier;

import io.vavr.control.Either;
import no.javazone.switcharoo.api.model.Service;

public class ServiceVerifier {

    public static Either<String, Service> verify(Service service) {
        return service.key == null ? Either.left("Key was empty")
            : service.value == null ? Either.left("Value was empty")
            : Either.right(service);
    }
}

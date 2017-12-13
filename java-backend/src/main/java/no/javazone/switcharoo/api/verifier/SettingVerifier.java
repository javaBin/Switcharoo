package no.javazone.switcharoo.api.verifier;

import io.vavr.control.Either;
import no.javazone.switcharoo.api.model.Setting;

public class SettingVerifier {

    public static Either<String, Setting> verify(Setting s) {
        return s.hint == null ? Either.left("Hint was null")
            : s.key == null ? Either.left("Key was null")
            : s.value == null ? Either.left("Value was null")
            : Either.right(s);
    }
}

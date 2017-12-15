package no.javazone.switcharoo;

import io.vavr.control.Either;
import io.vavr.control.Try;

public class Util {
    public static Either<String, Integer> parseInt(String id) {
        return Try.of(() -> Integer.parseInt(id)).toEither(String.format("Malformed id '%s'", id));
    }

    public static Either<String, Long> parseLong(String s) {
        return Try.of(() -> Long.parseLong(s)).toEither(String.format("Malformed long '%s'", s));
    }
}

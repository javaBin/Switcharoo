package no.javazone.switcharoo.exception;

public class BadRequestException extends RuntimeException {

    public final String reason;

    public BadRequestException(String reason) {
        this.reason = reason;
    }
}

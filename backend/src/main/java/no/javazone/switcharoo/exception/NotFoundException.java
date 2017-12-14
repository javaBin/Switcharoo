package no.javazone.switcharoo.exception;

public class NotFoundException extends RuntimeException {
    public final String reason;

    public NotFoundException(String reason) {
        this.reason = reason;
    }
}

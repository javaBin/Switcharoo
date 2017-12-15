package no.javazone.switcharoo.api.model;

public class Service {
    public final Long id;
    public final String key;
    public final Boolean value;

    public Service(Long id, String key, Boolean value) {
        this.id = id;
        this.key = key;
        this.value = value;
    }
}

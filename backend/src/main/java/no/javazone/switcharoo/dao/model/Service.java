package no.javazone.switcharoo.dao.model;

public class Service {
    public final Long id;
    public final String key;
    public final Boolean value;

    public Service(Long id, String key, Boolean value) {
        this.id = id;
        this.key = key;
        this.value = value;
    }

    public Service withId(final long id) {
        return new Service(id, key, value);
    }
}

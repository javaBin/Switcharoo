package no.javazone.switcharoo.dao.model;

public class DBService {
    public final Long id;
    public final String key;
    public final Boolean value;

    public DBService(Long id, String key, Boolean value) {
        this.id = id;
        this.key = key;
        this.value = value;
    }

    public DBService withId(final long id) {
        return new DBService(id, key, value);
    }
}

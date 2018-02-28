package no.javazone.switcharoo.dao.model;

public class DBConference {

    public final Long id;
    public final String name;

    public DBConference(Long id, String name) {
        this.id = id;
        this.name = name;
    }

    public DBConference withId(Long id) {
        return new DBConference(id, name);
    }
}

package no.javazone.switcharoo.dao.model;

public class Conference {

    public final Long id;
    public final String name;

    public Conference(Long id, String name) {
        this.id = id;
        this.name = name;
    }

    public Conference withId(Long id) {
        return new Conference(id, name);
    }
}

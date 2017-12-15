package no.javazone.switcharoo.dao.model;

public class Css {
    public final Long id;
    public final String selector;
    public final String property;
    public final String value;
    public final String type;
    public final String title;

    public Css(long id, String selector, String property, String value, String type, String title) {
        this.id = id;
        this.selector = selector;
        this.property = property;
        this.value = value;
        this.type = type;
        this.title = title;
    }

    public Css withId(long id) {
        return new Css(
            id,
            selector,
            property,
            value,
            type,
            title
        );
    }
}

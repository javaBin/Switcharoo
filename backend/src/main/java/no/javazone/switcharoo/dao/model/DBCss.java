package no.javazone.switcharoo.dao.model;

public class DBCss {
    public final Long id;
    public final String selector;
    public final String property;
    public final String value;
    public final String type;
    public final String title;

    public DBCss(long id, String selector, String property, String value, String type, String title) {
        this.id = id;
        this.selector = selector;
        this.property = property;
        this.value = value;
        this.type = type;
        this.title = title;
    }

    public DBCss withId(long id) {
        return new DBCss(
            id,
            selector,
            property,
            value,
            type,
            title
        );
    }
}

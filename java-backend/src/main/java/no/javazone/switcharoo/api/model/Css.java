package no.javazone.switcharoo.api.model;

public class Css {
    public final Long id;
    public final String selector;
    public final String property;
    public final String value;
    public final String type;
    public final String title;

    public Css(Long id, String selector, String property, String value, String type, String title) {
        this.id = id;
        this.selector = selector;
        this.property = property;
        this.value = value;
        this.type = type;
        this.title = title;
    }
}

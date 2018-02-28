package no.javazone.switcharoo.dao.model;

public class DBSlide {

    public final Long id;
    public final String title;
    public final String body;
    public final boolean visible;
    public final String type;
    public final int index;
    public final String name;
    public final String color;

    public DBSlide(Long id, String title, String body, boolean visible, String type, int index, String name, String color) {
        this.id = id;
        this.title = title;
        this.body = body;
        this.visible = visible;
        this.type = type;
        this.index = index;
        this.name = name;
        this.color = color;
    }

    public DBSlide withId(Long id) {
        return new DBSlide(id, title, body, visible, type, index, name, color);
    }
}

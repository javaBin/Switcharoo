package no.javazone.switcharoo.api.model;

public class Slide {

    public final Long id;
    public final String title;
    public final String body;
    public final Boolean visible;
    public final String type;
    public final Integer index;
    public final String name;
    public final String color;
    public final int duration = 10_000;

    public Slide(long id, String title, String body, boolean visible, String type, int index, String name, String color) {
        this.id = id;
        this.title = title;
        this.body = body;
        this.visible = visible;
        this.type = type;
        this.index = index;
        this.name = name;
        this.color = color;
    }
}

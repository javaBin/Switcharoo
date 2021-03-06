package no.javazone.switcharoo.api.model;

public class Overlay {

    public final Boolean enabled;
    public final String image;
    public final String placement;
    public final String width;
    public final String height;

    public Overlay(Boolean enabled, String image, String placement, String width, String height) {
        this.enabled = enabled;
        this.image = image;
        this.placement = placement;
        this.width = width;
        this.height = height;
    }
}

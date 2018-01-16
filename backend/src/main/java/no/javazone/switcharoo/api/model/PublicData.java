package no.javazone.switcharoo.api.model;

import java.util.List;

public class PublicData {

    public final List<Object> slides;
    public final Overlay overlay;

    public PublicData(List<Object> slides) {
        this.slides = slides;
        overlay = new Overlay();
    }
}

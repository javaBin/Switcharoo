package no.javazone.switcharoo.api.model;

import io.vavr.collection.List;

public class PublicData {

    public final List<Object> slides;
    public final Overlay overlay;

    public PublicData(List<Object> slides) {
        this.slides = slides;
        this.overlay = null;
        //overlay = new Overlay();
    }
}

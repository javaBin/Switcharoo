package no.javazone.switcharoo.api.model;

import no.javazone.switcharoo.service.domain.SlotItem;

import java.util.List;

public class ProgramSlide {
    public final String type = "program";
    public final String heading;
    public final List<SlotItem> presentations;

    public ProgramSlide(String heading, List<SlotItem> presentations) {
        this.heading = heading;
        this.presentations = presentations;
    }
}

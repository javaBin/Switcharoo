package no.javazone.switcharoo.api.mapper;

import no.javazone.switcharoo.api.model.Slide;

public class SlideMapper {

    public static Slide fromDb(no.javazone.switcharoo.dao.model.Slide slide) {
        return new Slide(
            slide.id,
            slide.title,
            slide.body,
            slide.visible,
            slide.type,
            slide.index,
            slide.name,
            slide.color
        );
    }

    public static no.javazone.switcharoo.dao.model.Slide toDb(Slide slide) {
        return new no.javazone.switcharoo.dao.model.Slide(
            slide.id,
            slide.title,
            slide.body,
            slide.visible,
            slide.type,
            slide.index,
            slide.name,
            slide.color
        );
    }

}

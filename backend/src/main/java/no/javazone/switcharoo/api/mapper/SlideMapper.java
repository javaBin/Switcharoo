package no.javazone.switcharoo.api.mapper;

import no.javazone.switcharoo.api.model.Slide;
import no.javazone.switcharoo.dao.model.DBSlide;

public class SlideMapper {

    public static Slide fromDb(DBSlide slide) {
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

    public static DBSlide toDb(Slide slide) {
        return new DBSlide(
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

package no.javazone.switcharoo.api.mapper;

import no.javazone.switcharoo.api.model.Css;

public class CssMapper {

    public static Css fromDb(no.javazone.switcharoo.dao.model.Css css) {
        return new Css(
            css.id,
            css.selector,
            css.property,
            css.value,
            css.type,
            css.title
        );
    }

    public static no.javazone.switcharoo.dao.model.Css toDb(Css css) {
        return new no.javazone.switcharoo.dao.model.Css(
            css.id,
            css.selector,
            css.property,
            css.value,
            css.type,
            css.title
        );
    }
}

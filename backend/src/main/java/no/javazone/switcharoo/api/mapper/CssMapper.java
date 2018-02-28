package no.javazone.switcharoo.api.mapper;

import no.javazone.switcharoo.api.model.Css;
import no.javazone.switcharoo.dao.model.DBCss;

public class CssMapper {

    public static Css fromDb(DBCss css) {
        return new Css(
            css.id,
            css.selector,
            css.property,
            css.value,
            css.type,
            css.title
        );
    }

    public static DBCss toDb(Css css) {
        return new DBCss(
            css.id,
            css.selector,
            css.property,
            css.value,
            css.type,
            css.title
        );
    }
}

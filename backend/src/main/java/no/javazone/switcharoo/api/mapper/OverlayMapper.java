package no.javazone.switcharoo.api.mapper;

import no.javazone.switcharoo.api.model.Overlay;
import no.javazone.switcharoo.dao.model.DBOverlay;

public class OverlayMapper {

    public static Overlay fromDb(DBOverlay overlay) {
        if (overlay.image == null || overlay.image.equals("") || !overlay.enabled) {
            return null;
        } else {
            return new Overlay(overlay.enabled, overlay.image, overlay.placement, overlay.width, overlay.height);
        }
    }

    public static DBOverlay toDb(Overlay overlay) {
        return new DBOverlay(overlay.enabled, overlay.image, overlay.placement, overlay.width, overlay.height);
    }
}

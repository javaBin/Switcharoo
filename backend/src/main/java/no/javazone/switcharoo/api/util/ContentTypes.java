package no.javazone.switcharoo.api.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashMap;
import java.util.Map;

public class ContentTypes {

    private static final Logger LOG = LoggerFactory.getLogger(ContentTypes.class);
    private static final Map<String, String> contentTypes = new HashMap<>();

    static {
        contentTypes.put("html", "text/html; charset=utf-8");
        contentTypes.put("js", "application/javascript");
        contentTypes.put("css", "text/css");
        contentTypes.put("woff", "font/woff");

        contentTypes.put("webm", "video/webm");

        contentTypes.put("jpg", "image/jpeg");
        contentTypes.put("jpeg", "image/jpeg");
        contentTypes.put("png", "image/png");
        contentTypes.put("svg", "image/svg+xml");

    }

    public static String get(String fileType) {
        String contentType = contentTypes.get(fileType);
        if (contentType == null) {
            LOG.warn("Could not find content type for file type '{}'", fileType);
            contentType = "text/html";
        }
        return contentType;
    }
}

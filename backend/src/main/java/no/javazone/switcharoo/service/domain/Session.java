package no.javazone.switcharoo.service.domain;

import java.time.ZonedDateTime;
import java.util.List;

public class Session {
    public String format;
    public String room;
    public String title;
    public String length;
    public ZonedDateTime startTimeZulu;
    public ZonedDateTime endTimeZulu;
    public List<Speaker> speakers;

    @Override
    public String toString() {
        return "Session{" +
            "format='" + format + '\'' +
            ", room='" + room + '\'' +
            ", title='" + title + '\'' +
            ", length='" + length + '\'' +
            ", startTimeZulu=" + startTimeZulu +
            ", endTimeZulu=" + endTimeZulu +
            ", speakers=" + speakers +
            '}';
    }
}

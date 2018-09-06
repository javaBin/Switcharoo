package no.javazone.switcharoo.service.domain;

import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

public class Slot {
    public ZonedDateTime start;
    public ZonedDateTime end;
    public List<SlotItem> sessions;

    public Slot(ZonedDateTime start, ZonedDateTime end) {
        this.start = start;
        this.end = end;
        this.sessions = new ArrayList<>();
    }

    @Override
    public String toString() {
        return "Slot{" +
            "start=" + start +
            ", end=" + end +
            ", n=" + sessions.size() +
            '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Slot slot = (Slot) o;
        return Objects.equals(start, slot.start) &&
            Objects.equals(end, slot.end);
    }

    @Override
    public int hashCode() {
        return Objects.hash(start, end);
    }
}

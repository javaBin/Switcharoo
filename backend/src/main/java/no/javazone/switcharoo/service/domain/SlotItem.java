package no.javazone.switcharoo.service.domain;

import java.util.Objects;

public class SlotItem {
    public String title;
    public String speakers;
    public String room;

    public SlotItem(String title, String speakers, String room) {
        this.title = title;
        this.speakers = speakers;
        this.room = room;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        SlotItem slotItem = (SlotItem) o;
        return Objects.equals(title, slotItem.title) &&
            Objects.equals(speakers, slotItem.speakers) &&
            Objects.equals(room, slotItem.room);
    }

    @Override
    public int hashCode() {
        return Objects.hash(title, speakers, room);
    }
}

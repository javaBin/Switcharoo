package no.javazone.switcharoo.api.mapper;

import no.javazone.switcharoo.api.model.Conference;

public class ConferenceMapper {

    public static no.javazone.switcharoo.dao.model.Conference toDb(Conference conference) {
        return new no.javazone.switcharoo.dao.model.Conference(conference.id, conference.name);
    }

    public static Conference fromDb(no.javazone.switcharoo.dao.model.Conference conference) {
        return new Conference(conference.id, conference.name);
    }
}

package no.javazone.switcharoo.api.mapper;

import no.javazone.switcharoo.api.model.Conference;
import no.javazone.switcharoo.dao.model.DBConference;

public class ConferenceMapper {

    public static DBConference toDb(Conference conference) {
        return new DBConference(conference.id, conference.name);
    }

    public static Conference fromDb(DBConference conference) {
        return new Conference(conference.id, conference.name);
    }
}

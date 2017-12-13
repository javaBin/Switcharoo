package no.javazone.switcharoo.api.mapper;

import no.javazone.switcharoo.api.model.Service;

public class ServiceMapper {

    public static Service fromDb(no.javazone.switcharoo.dao.model.Service service) {
        return new Service(service.id, service.key, service.value);
    }

    public static no.javazone.switcharoo.dao.model.Service toDb(Service service) {
        return new no.javazone.switcharoo.dao.model.Service(
            service.id,
            service.key,
            service.value
        );
    }
}

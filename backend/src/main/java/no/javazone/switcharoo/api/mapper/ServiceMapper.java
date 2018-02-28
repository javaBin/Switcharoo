package no.javazone.switcharoo.api.mapper;

import no.javazone.switcharoo.api.model.Service;
import no.javazone.switcharoo.dao.model.DBService;

public class ServiceMapper {

    public static Service fromDb(DBService service) {
        return new Service(service.id, service.key, service.value);
    }

    public static DBService toDb(Service service) {
        return new DBService(
            service.id,
            service.key,
            service.value
        );
    }
}

package no.javazone.switcharoo.dao.utils;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.SQLException;

public interface SqlFunction<T, U> {

    Logger LOG = LoggerFactory.getLogger(SqlFunction.class);

    default U apply(final T t) {
        try {
            return acceptThrows(t);
        } catch (SQLException e) {
            LOG.error("SQLException", e);
            throw new RuntimeException(e);
        }
    }

    U acceptThrows(T t) throws SQLException;
}

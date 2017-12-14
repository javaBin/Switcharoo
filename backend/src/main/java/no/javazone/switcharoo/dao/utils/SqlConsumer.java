package no.javazone.switcharoo.dao.utils;

import io.vavr.control.Try;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.SQLException;
import java.sql.Statement;

@FunctionalInterface
public interface SqlConsumer<T> {

    Logger LOG = LoggerFactory.getLogger(SqlConsumer.class);

    default Try<T> apply(final Statement st, final int i) {
        try {
            T result = acceptThrows(st, i);
            if (result == null) {
                return Try.failure(new RuntimeException());
            } else {
                return Try.of(() -> result);
            }
        } catch (SQLException s) {
            LOG.error("SQLException", s);
            return Try.failure(s);
        }
    }

    T acceptThrows(Statement s, int i) throws SQLException;
}

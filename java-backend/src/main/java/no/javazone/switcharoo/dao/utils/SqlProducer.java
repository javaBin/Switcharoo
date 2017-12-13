package no.javazone.switcharoo.dao.utils;

import io.vavr.control.Try;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.ResultSet;
import java.sql.SQLException;

@FunctionalInterface
public interface SqlProducer<T> {

    Logger LOG = LoggerFactory.getLogger(SqlFunction.class);

    default Try<T> apply(final ResultSet rs) {
        try {
            T result = acceptThrows(rs);
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

    T acceptThrows(ResultSet s) throws SQLException;
}

package no.javazone.switcharoo.dao.utils;

import io.vavr.control.Either;
import io.vavr.control.Try;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.sql.DataSource;
import java.sql.*;

public class DBUtils {

    static Logger LOG = LoggerFactory.getLogger(DBUtils.class);

    public static <T> Try<T> query(DataSource dataSource, String query, SqlProducer<T> fn) {
        try (Connection connection = dataSource.getConnection()) {
            try (Statement statement = connection.createStatement()) {
                try (ResultSet rs = statement.executeQuery(query)) {
                    LOG.info("Executing query \"{}\"", query);
                    return fn.apply(rs);
                }
            }
        } catch (SQLException e) {
            LOG.error("SQLException", e);
            return Try.failure(e);
        }
    }

    public static <T> Either<String, T> query(DataSource dataSource, SqlFunction<Connection, PreparedStatement> a, SqlProducer<T> fn, String error) {
        try (Connection connection = dataSource.getConnection()) {
            try (PreparedStatement statement = a.apply(connection)) {
                try (ResultSet rs = statement.executeQuery()) {
                    LOG.info("Executing query \"{}\"", statement.toString());
                    return fn.apply(rs).toEither(error);
                }
            }
        } catch (SQLException e) {
            LOG.error("SQLException", e);
            return Either.left(e.getMessage());
        }
    }

    public static <T> Either<String, T> updateQuery(DataSource dataSource, SqlFunction<Connection, PreparedStatement> a, SqlConsumer<T> fn, String error) {
        try (Connection connection = dataSource.getConnection()) {
            try (PreparedStatement statement = a.apply(connection)) {
                LOG.info("Executing query \"{}\"", statement.toString());
                int i = statement.executeUpdate();
                return fn.apply(statement, i).toEither(error);
            }
        } catch (SQLException e) {
            LOG.error("SQLException", e);
            return Either.left(e.getMessage());
        }
    }
}

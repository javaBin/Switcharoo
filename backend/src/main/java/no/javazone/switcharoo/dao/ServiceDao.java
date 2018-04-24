package no.javazone.switcharoo.dao;

import io.vavr.collection.List;
import io.vavr.control.Either;
import no.javazone.switcharoo.dao.model.DBService;

import javax.sql.DataSource;

import java.sql.*;
import java.time.Instant;

import static no.javazone.switcharoo.dao.utils.DBUtils.query;
import static no.javazone.switcharoo.dao.utils.DBUtils.updateQuery;

public class ServiceDao {

    private final DataSource dataSource;

    public ServiceDao(DataSource dataSource) {

        this.dataSource = dataSource;
    }

    public List<DBService> list(final long conferenceId) {
        String sql = "SELECT * FROM services WHERE conference_id = ? ORDER BY id";
        return query(dataSource, c -> {
            PreparedStatement p = c.prepareStatement(sql);
            p.setLong(1, conferenceId);
            return p;
        }, rs -> {
            List<DBService> services = List.empty();
            while (rs.next()) {
                services = services.append(fromResultSet(rs));
            }
            return services;
        }, "No services found for conference").getOrElse(List::empty);
    }

    public Either<String, DBService> get(final long id, final long conferenceId) {
        String sql = "SELECT * FROM services WHERE id = ? AND conference_id = ?";
        return query(dataSource, c -> {
            PreparedStatement p = c.prepareStatement(sql);
            p.setLong(1, id);
            p.setLong(2, conferenceId);
            return p;
        }, rs -> {
            if (rs.next()) {
                return fromResultSet(rs);
            } else {
                return null;
            }
        }, "Could not find service");
    }

    public Either<String, DBService> getByKey(final String key, final long conferenceId) {
        String sql = "SELECT * FROM services WHERE key = ? AND conference_id = ?";
        return query(dataSource, c -> {
            PreparedStatement p = c.prepareStatement(sql);
            p.setString(1, key);
            p.setLong(2, conferenceId);
            return p;
        }, rs -> {
            if (rs.next()) {
                return fromResultSet(rs);
            } else {
                return null;
            }
        }, String.format("Could not find service named '%s'", key));
    }

    public Either<String, DBService> create(final DBService service, final long conferenceId) {
        String sql = "INSERT INTO services(key, value, conference_id) VALUES(?, ?, ?)";
        return updateQuery(dataSource, c -> {
            PreparedStatement p = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            p.setString(1, service.key);
            p.setBoolean(2, service.value);
            p.setLong(3, conferenceId);
            return p;
        }, (st, i) -> {
            ResultSet keySet = st.getGeneratedKeys();
            if (keySet.next()) {
                return service.withId(keySet.getLong(1));
            } else {
                return null;
            }
        }, "Could not create service");
    }

    public Either<String, DBService> update(final long id, final long conferenceId) {
        String sql = "UPDATE services SET value = ?, updated_at = ? WHERE id = ?";
        return get(id, conferenceId).flatMap(service -> updateQuery(dataSource, c -> {
            PreparedStatement p = c.prepareStatement(sql);
            p.setBoolean(1, !service.value);
            p.setTimestamp(2, Timestamp.from(Instant.now()));
            p.setLong(3, id);
            return p;
        }, (st, i) -> i > 0 ? service : null, "Could not update service"));
    }

    // TODO: Need to rewrite frontend and use this update function instead
    /*public Either<String, DBService> update(final DBService service) {
        String sql = "UPDATE services SET key = ?, value = ? WHERE id = ?";
        return updateQuery(dataSource, c -> {
            PreparedStatement p = c.prepareStatement(sql);
            p.setString(1, service.key);
            p.setBoolean(2, service.value);
            p.setLong(3, service.id);
            return p;
        }, (st, i) -> i > 0 ? service : null, "Could not update service");
    }*/

    public Either<String, Boolean> delete(final long id) {
        String sql = "DELETE FROM services WHERE id = ?";
        return updateQuery(dataSource, c -> {
            PreparedStatement p = c.prepareStatement(sql);
            p.setLong(1, id);
            return p;
        }, (st, i) -> i > 0, "Could not delete service");
    }

    private DBService fromResultSet(ResultSet rs) throws SQLException {
        return new DBService(
            rs.getLong("id"),
            rs.getString("key"),
            rs.getBoolean("value")
        );
    }
}

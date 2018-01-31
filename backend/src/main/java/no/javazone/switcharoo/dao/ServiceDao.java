package no.javazone.switcharoo.dao;

import io.vavr.collection.List;
import io.vavr.control.Either;
import no.javazone.switcharoo.dao.model.Service;

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

    public List<Service> list() {
        String sql = "SELECT * FROM services ORDER BY id";
        return query(dataSource, sql, rs -> {
            List<Service> services = List.empty();
            while (rs.next()) {
                services = services.append(fromResultSet(rs));
            }
            return services;
        }).getOrElse(List::empty);
    }

    public Either<String, Service> get(final long id) {
        String sql = "SELECT * FROM services WHERE id = ?";
        return query(dataSource, c -> {
            PreparedStatement p = c.prepareStatement(sql);
            p.setLong(1, id);
            return p;
        }, rs -> {
            if (rs.next()) {
                return fromResultSet(rs);
            } else {
                return null;
            }
        }, "Could not find service");
    }

    public Either<String, Service> getByKey(final String key) {
        String sql = "SELECT * FROM services WHERE key = ?";
        return query(dataSource, c -> {
            PreparedStatement p = c.prepareStatement(sql);
            p.setString(1, key);
            return p;
        }, rs -> {
            if (rs.next()) {
                return fromResultSet(rs);
            } else {
                return null;
            }
        }, String.format("Could not find service named %s", key));
    }

    public Either<String, Service> create(final Service service) {
        String sql = "INSERT INTO services(key, value) VALUES(?, ?)";
        return updateQuery(dataSource, c -> {
            PreparedStatement p = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            p.setString(1, service.key);
            p.setBoolean(2, service.value);
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

    public Either<String, Service> update(final long id) {
        String sql = "UPDATE services SET value = ?, updated_at = ? WHERE id = ?";
        return get(id).flatMap(service -> updateQuery(dataSource, c -> {
            PreparedStatement p = c.prepareStatement(sql);
            p.setBoolean(1, !service.value);
            p.setTimestamp(2, Timestamp.from(Instant.now()));
            p.setLong(3, id);
            return p;
        }, (st, i) -> i > 0 ? service : null, "Could not update service"));
    }

    // TODO: Need to rewrite frontend and use this update function instead
    /*public Either<String, Service> update(final Service service) {
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

    private Service fromResultSet(ResultSet rs) throws SQLException {
        return new Service(
            rs.getLong("id"),
            rs.getString("key"),
            rs.getBoolean("value")
        );
    }
}
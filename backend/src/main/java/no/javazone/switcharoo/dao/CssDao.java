package no.javazone.switcharoo.dao;

import io.vavr.collection.List;
import io.vavr.control.Either;
import no.javazone.switcharoo.dao.model.DBCss;

import javax.sql.DataSource;

import java.sql.*;
import java.time.Instant;

import static no.javazone.switcharoo.dao.utils.DBUtils.query;
import static no.javazone.switcharoo.dao.utils.DBUtils.updateQuery;

public class CssDao {

    private final DataSource dataSource;

    public CssDao(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    public List<DBCss> list(final long conferenceId) {
        String sql = "SELECT * FROM csses WHERE conference_id = ? ORDER BY id";
        return query(dataSource, c -> {
            PreparedStatement p = c.prepareStatement(sql);
            p.setLong(1, conferenceId);
            return p;
        }, rs -> {
            List<DBCss> csses = List.empty();
            while (rs.next()) {
                csses = csses.append(fromResultSet(rs));
            }
            return csses;
        }, "No css found for conference").getOrElse(List::empty);
    }

    public Either<String, DBCss> get(final long id, final long conferenceId) {
        String sql = "SELECT * FROM csses WHERE id = ? AND conference_id = ?";
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
        }, "Could not find css");
    }

    public Either<String, DBCss> create(final DBCss css, final long conferenceId) {
        String sql = "INSERT INTO csses(selector, property, value, type, title, confereice_id) VALUES(?, ?, ?, ?, ?, ?)";
        return updateQuery(dataSource, c -> {
            PreparedStatement p = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            p.setString(1, css.selector);
            p.setString(2, css.property);
            p.setString(3, css.value);
            p.setString(4, css.type);
            p.setString(5, css.title);
            p.setLong(6, conferenceId);
            return p;
        }, (st, i) -> {
            ResultSet rs = st.getGeneratedKeys();
            if (rs.next()) {
                return css.withId(rs.getLong("id"));
            } else {
                return null;
            }
        }, "Could not create css");
    }

    public Either<String, DBCss> update(final DBCss css, final long conferenceId) {
        String sql = "UPDATE csses SET selector = ?, property = ?, value = ?, type = ?, title = ?, updated_at = ? WHERE id = ?";
        return get(css.id, conferenceId).flatMap(dbCss -> updateQuery(dataSource, c -> {
            PreparedStatement p = c.prepareStatement(sql);
            p.setString(1, css.selector);
            p.setString(2, css.property);
            p.setString(3, css.value);
            p.setString(4, css.type);
            p.setString(5, css.title);
            p.setTimestamp(6, Timestamp.from(Instant.now()));
            p.setLong(7, css.id);
            return p;
        }, (st, i) -> i > 0 ? css : null, "Could not update css"));
    }

    public Either<String, Boolean> delete(final long id) {
        String sql = "DELETE FROM  csses WHERE id = ?";
        return updateQuery(dataSource, c -> {
            PreparedStatement p = c.prepareStatement(sql);
            p.setLong(1, id);
            return p;
        }, (st, i) -> i > 0, "Could not delete Css");
    }

    private static DBCss fromResultSet(ResultSet rs) throws SQLException {
        return new DBCss(
            rs.getLong("id"),
            rs.getString("selector"),
            rs.getString("property"),
            rs.getString("value"),
            rs.getString("type"),
            rs.getString("title")
        );
    }

}

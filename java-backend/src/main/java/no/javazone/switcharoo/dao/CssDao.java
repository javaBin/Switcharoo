package no.javazone.switcharoo.dao;

import io.vavr.collection.List;
import io.vavr.control.Either;
import no.javazone.switcharoo.dao.model.Css;

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

    public List<Css> list() {
        String sql = "SELECT * FROM csses ORDER BY id";
        return query(dataSource, sql, rs -> {
            List<Css> csses = List.empty();
            while (rs.next()) {
                csses = csses.append(fromResultSet(rs));
            }
            return csses;
        }).getOrElse(List::empty);
    }

    public Either<String, Css> get(final long id) {
        String sql = "SELECT * FROM csses WHERE id = ?";
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
        }, "Could not find css");
    }

    public Either<String, Css> create(final Css css) {
        String sql = "INSERT INTO csses(selector, property, value, type, title) VALUES(?, ?, ?, ?, ?)";
        return updateQuery(dataSource, c -> {
            PreparedStatement p = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            p.setString(1, css.selector);
            p.setString(2, css.property);
            p.setString(3, css.value);
            p.setString(4, css.type);
            p.setString(5, css.title);
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

    public Either<String, Css> update(final Css css) {
        String sql = "UPDATE csses SET selector = ?, property = ?, value = ?, type = ?, title = ?, updated_at = ? WHERE id = ?";
        return get(css.id).flatMap(dbCss -> updateQuery(dataSource, c -> {
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

    private static Css fromResultSet(ResultSet rs) throws SQLException {
        return new Css(
            rs.getLong("id"),
            rs.getString("selector"),
            rs.getString("property"),
            rs.getString("value"),
            rs.getString("type"),
            rs.getString("title")
        );
    }

}

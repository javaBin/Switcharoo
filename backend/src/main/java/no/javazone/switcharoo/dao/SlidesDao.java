package no.javazone.switcharoo.dao;

import io.vavr.collection.List;
import io.vavr.control.Either;
import no.javazone.switcharoo.dao.model.DBSlide;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.sql.DataSource;

import java.sql.*;
import java.time.Instant;

import static no.javazone.switcharoo.dao.utils.DBUtils.query;
import static no.javazone.switcharoo.dao.utils.DBUtils.updateQuery;

public class SlidesDao {

    static Logger LOG = LoggerFactory.getLogger(SlidesDao.class);
    private final DataSource dataSource;

    public SlidesDao(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    public List<DBSlide> list(final long conferenceId) {
        return listWithSql("SELECT * FROM slides WHERE conference_id = ? ORDER BY index", conferenceId);
    }

    public List<DBSlide> listVisible(final long conferenceId) {
        return listWithSql("SELECT * FROM slides WHERE visible = true AND conference_id = ? ORDER BY index", conferenceId);
    }

    private List<DBSlide> listWithSql(String sql, final long conferenceId) {
        return query(dataSource, c -> {
            PreparedStatement p = c.prepareStatement(sql);
            p.setLong(1, conferenceId);
            return p;
        }, rs -> {
            List<DBSlide> slides = List.empty();
            while (rs.next()) {
                slides = slides.append(fromResultSet(rs));
            }
            return slides;
        }, "No slides found for conference " + conferenceId).getOrElse(List::empty);
    }

    public Either<String, DBSlide> get(final long id, final long conferenceId) {
        String sql = "SELECT * FROM slides WHERE id = ? AND conference_id = ?";
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
        }, "Could not find slide");
    }

    public Either<String, DBSlide> create(final DBSlide slide, final long conferenceId) {
        String sql = "INSERT INTO slides(title, body, visible, type, index, name, color, conference_id) VALUES(?, ?, ?, ?, ?, ?, ?, ?)";
        return updateQuery(dataSource, c -> {
            PreparedStatement p = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            p.setString(1, slide.title);
            p.setString(2, slide.body);
            p.setBoolean(3, slide.visible);
            p.setString(4, slide.type);
            p.setInt(5, slide.index);
            p.setString(6, slide.name);
            p.setString(7, slide.color);
            p.setLong(8, conferenceId);
            return p;
        }, (st, i) -> {
            ResultSet keySet = st.getGeneratedKeys();
            if (keySet.next()) {
                return slide.withId(keySet.getLong(1));
            } else {
                return null;
            }
        }, "Could not create slide");
    }

    public Either<String, DBSlide> update(final DBSlide slide, final long conferenceId) {
        String sql = "UPDATE slides SET title = ?, body = ?, visible = ?, type = ?, index = ?, name = ?, color = ?, updated_at = ? WHERE id = ?";
        return get(slide.id, conferenceId).flatMap(dbSlide -> updateQuery(dataSource, c -> {
            PreparedStatement p = c.prepareStatement(sql);
            p.setString(1, slide.title);
            p.setString(2, slide.body);
            p.setBoolean(3, slide.visible);
            p.setString(4, slide.type);
            p.setInt(5, slide.index);
            p.setString(6, slide.name);
            p.setString(7, slide.color);
            p.setTimestamp(8, Timestamp.from(Instant.now()));
            p.setLong(9, slide.id);
            return p;
        }, (st, i) -> i > 0 ? slide : null,
            "Could not update slide"));
    }

    public Either<String, Boolean> delete(final long id) {
        String sql = "DELETE FROM slides WHERE id = ?";
        return updateQuery(dataSource, c -> {
            PreparedStatement p = c.prepareStatement(sql);
            p.setLong(1, id);
            return p;
        }, (st, i) -> i > 0, "Could not delete setting");
    }

    private static DBSlide fromResultSet(ResultSet rs) throws SQLException {
        return new DBSlide(rs.getLong("id"),
            rs.getString("title"),
            rs.getString("body"),
            rs.getBoolean("visible"),
            rs.getString("type"),
            rs.getInt("index"),
            rs.getString("name"),
            rs.getString("color")
        );
    }

    public Either<String, Boolean> updateIndexes(final List<Long> ids, final long conferenceId) {
        String indexes = String.join(",", ids.zipWithIndex().map(t -> t.toString()).toJavaList());
        String sql = String.format("UPDATE slides AS s SET index = c.index FROM (values %s) AS c(id, index) WHERE c.id = s.id AND conference_id = ?", indexes);
        return updateQuery(dataSource, c -> {
             PreparedStatement p = c.prepareStatement(sql);
             p.setLong(1, conferenceId);
             return p;
            },
            (st, i) -> {
                if (i == ids.length()) {
                    return true;
                } else {
                    LOG.warn("Update failed. Tried updating {} rows, only updated {}", ids.length(), i);
                    return false;
                }
            }, "Could not update indexes");
    }
}

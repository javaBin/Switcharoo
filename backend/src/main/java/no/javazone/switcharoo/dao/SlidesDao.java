package no.javazone.switcharoo.dao;

import io.vavr.collection.List;
import io.vavr.control.Either;
import no.javazone.switcharoo.dao.model.Slide;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.sql.DataSource;

import java.sql.*;
import java.time.Instant;
import java.time.LocalDateTime;

import static no.javazone.switcharoo.dao.utils.DBUtils.query;
import static no.javazone.switcharoo.dao.utils.DBUtils.updateQuery;

public class SlidesDao {

    static Logger LOG = LoggerFactory.getLogger(SlidesDao.class);
    private final DataSource dataSource;

    public SlidesDao(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    public List<Slide> list() {
        return listWithSql("SELECT * FROM slides ORDER BY index");
    }

    public List<Slide> listVisible() {
        return listWithSql("SELECT * FROM slides WHERE visible = true ORDER BY index");
    }

    private List<Slide> listWithSql(String sql) {
        return query(dataSource, sql, rs -> {
            List<Slide> slides = List.empty();
            while (rs.next()) {
                slides = slides.append(fromResultSet(rs));
            }
            return slides;
        }).getOrElse(List::empty);
    }

    public Either<String, Slide> get(final long id) {
        String sql = "SELECT * FROM slides WHERE id = ?";
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
        }, "Could not find slide");
    }

    public Either<String, Slide> create(final Slide slide) {
        String sql = "INSERT INTO slides(title, body, visible, type, index, name, color) VALUES(?, ?, ?, ?, ?, ?, ?)";
        return updateQuery(dataSource, c -> {
            PreparedStatement p = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            p.setString(1, slide.title);
            p.setString(2, slide.body);
            p.setBoolean(3, slide.visible);
            p.setString(4, slide.type);
            p.setInt(5, slide.index);
            p.setString(6, slide.name);
            p.setString(7, slide.color);
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

    public Either<String, Slide> update(final Slide slide) {
        String sql = "UPDATE slides SET title = ?, body = ?, visible = ?, type = ?, index = ?, name = ?, color = ?, updated_at = ? WHERE id = ?";
        return get(slide.id).flatMap(dbSlide -> updateQuery(dataSource, c -> {
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

    private static Slide fromResultSet(ResultSet rs) throws SQLException {
        return new Slide(rs.getLong("id"),
            rs.getString("title"),
            rs.getString("body"),
            rs.getBoolean("visible"),
            rs.getString("type"),
            rs.getInt("index"),
            rs.getString("name"),
            rs.getString("color")
        );
    }
}

package no.javazone.switcharoo.dao;

import io.vavr.collection.List;
import io.vavr.control.Either;
import no.javazone.switcharoo.dao.model.Conference;

import javax.sql.DataSource;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import static no.javazone.switcharoo.dao.utils.DBUtils.query;
import static no.javazone.switcharoo.dao.utils.DBUtils.updateQuery;

public class ConferenceDao {
    private final DataSource dataSource;

    public ConferenceDao(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    public List<Conference> list() {
        return query(dataSource, "SELECT * FROM conferences", rs -> {
            List<Conference> conferences = List.empty();
            while(rs.next()) {
                conferences = conferences.append(fromResultSet(rs));
            }
            return conferences;
        }).getOrElse(List::empty);
    }

    public Either<String, Conference> get(final long id) {
        String sql = "SELECT * FROM conferences WHERE id = ?";
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
        }, "Could not find conference");
    }

    public Either<String, Conference> getByName(final String name) {
        String sql = "SELECT * FROM conferences WHERE name = ?";
        return query(dataSource, c -> {
            PreparedStatement p = c.prepareStatement(sql);
            p.setString(1, name);
            return p;
        }, rs -> {
            if (rs.next()) {
                return fromResultSet(rs);
            } else {
                return null;
            }
        }, "Could not find conference");
    }

    public Either<String, Conference> create(final Conference conference) {
        String sql = "INSERT INTO conferences (name) VALUES (?)";
        return updateQuery(dataSource, c -> {
            PreparedStatement p = c.prepareStatement(sql);
            p.setString(1, conference.name);
            return p;
        }, (st, i) -> {
            ResultSet rs = st.getGeneratedKeys();
            if (rs.next()) {
                return conference.withId(rs.getLong(1));
            } else {
                return null;
            }
        }, "Could not create conference");
    }

    public Either<String, Conference> update(final Conference conference) {
        String sql = "UPDATE conferences SET name = ? WHERE id = ?";
        return get(conference.id).flatMap(dbConference -> updateQuery(dataSource, c -> {
            PreparedStatement p = c.prepareStatement(sql);
            p.setString(1, conference.name);
            p.setLong(2, conference.id);
            return p;
        }, (st, i) -> i > 0 ? conference : null, "Could not update conference"));
    }

    public Either<String, Boolean> delete(final long id) {
        String sql = "DELETE FROM conferences WHERE id = ?";
        return updateQuery(dataSource,c -> {
            PreparedStatement p = c.prepareStatement(sql);
            p.setLong(1, id);
            return p;
        }, (st, i) -> i > 0, "Could not delete slide");
    }

    private Conference fromResultSet(ResultSet rs) throws SQLException {
        return new Conference(rs.getLong("id"), rs.getString("name"));
    }
}

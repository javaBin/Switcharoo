package no.javazone.switcharoo.dao;

import io.vavr.collection.List;
import io.vavr.control.Either;
import no.javazone.switcharoo.dao.model.DBConference;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.sql.DataSource;
import java.sql.*;

import static no.javazone.switcharoo.dao.utils.DBUtils.query;
import static no.javazone.switcharoo.dao.utils.DBUtils.updateQuery;

public class ConferenceDao {
    static Logger LOG = LoggerFactory.getLogger(ConferenceDao.class);
    private final DataSource dataSource;

    public ConferenceDao(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    public List<DBConference> list() {
        return query(dataSource, "SELECT * FROM conferences ORDER BY id DESC", rs -> {
            List<DBConference> conferences = List.empty();
            while(rs.next()) {
                conferences = conferences.append(fromResultSet(rs));
            }
            return conferences;
        }).getOrElse(List::empty);
    }

    public Either<String, DBConference> get(final long id) {
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

    public Either<String, DBConference> create(final DBConference conference) {
        String sql = "INSERT INTO conferences (name) VALUES (?)";
        return updateQuery(dataSource, c -> {
            PreparedStatement p = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            p.setString(1, conference.name);
            return p;
        }, (st, i) -> {
            ResultSet rs = st.getGeneratedKeys();
            if (rs.next()) {
                return conference.withId(rs.getLong(1));
            } else {
                return null;
            }
        }, "Could not create conference").flatMap(newConference -> {
            String newConferenceSQL = "{call new_conference(?)}";
            try (Connection connection = dataSource.getConnection()) {
                try (CallableStatement statement = connection.prepareCall(newConferenceSQL)) {
                    statement.setInt(1, newConference.id.intValue());
                    statement.execute();
                    return Either.right(newConference);
                }
            } catch (SQLException e) {
                LOG.error("Could not create conference data", e);
                return Either.left("Could not create conference data");
            }
        });
    }

    public Either<String, DBConference> update(final DBConference conference) {
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

    private DBConference fromResultSet(ResultSet rs) throws SQLException {
        return new DBConference(rs.getLong("id"), rs.getString("name"));
    }
}

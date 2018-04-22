package no.javazone.switcharoo.dao;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import io.vavr.collection.List;
import io.vavr.control.Either;
import no.javazone.switcharoo.dao.model.DBSetting;
import org.postgresql.util.PGobject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.sql.DataSource;
import java.sql.*;
import java.time.Instant;

import static no.javazone.switcharoo.dao.utils.DBUtils.updateQuery;
import static no.javazone.switcharoo.dao.utils.DBUtils.query;

public class SettingsDao {

    private static Logger LOG = LoggerFactory.getLogger(SettingsDao.class);
    private final DataSource dataSource;
    private final Gson gson;

    public SettingsDao(DataSource dataSource, Gson gson) {
        this.dataSource = dataSource;
        this.gson = gson;
    }

    public List<DBSetting> list(final long conferenceId) {
        String sql = "SELECT * FROM settings WHERE conference_id = ? ORDER BY id";
        return query(dataSource, c -> {
            PreparedStatement p = c.prepareStatement(sql);
            p.setLong(1, conferenceId);
            return p;
        }, rs -> {
            List<DBSetting> settings = List.empty();
            while (rs.next()) {
                settings = settings.append(fromResultSet(rs, gson));
            }
            return settings;
        }, "Could not find settings for conference").getOrElse(List::empty);
    }

    public Either<String, DBSetting> get(final long id, final long conferenceId) {
        String sql = "SELECT * FROM settings WHERE id = ? AND conference_id = ?";
        return query(dataSource, c -> {
            PreparedStatement statement = c.prepareStatement(sql);
            statement.setLong(1, id);
            statement.setLong(2, conferenceId);
            return statement;
        }, rs -> {
            if (rs.next()) {
                return fromResultSet(rs, gson);
            } else {
                return null;
            }
        }, "Could not find setting");
    }

    public Either<String, DBSetting> getByKey(final String key, final long conferenceId) {
        String sql = "SELECT * FROM settings WHERE key = ? AND conference_id = ?";
        return query(dataSource,
            c -> {
                PreparedStatement p = c.prepareStatement(sql);
                p.setString(1, key);
                p.setLong(2, conferenceId);
                return p;
            },
            rs -> rs.next() ? fromResultSet(rs, gson) : null,
            String.format("Could not find setting with key %s", key)
        );
    }

    public Either<String, DBSetting> create(final DBSetting setting, final long conferenceId) {
        String sql = "INSERT INTO settings(key, hint, value, conference_id) VALUES(?, ?, ?, ?)";
        return updateQuery(dataSource, c -> {
            PreparedStatement s = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            s.setString(1, setting.key);
            s.setString(2, setting.hint);
            s.setObject(3, toJson(setting.value));
            s.setLong(4, conferenceId);
            return s;
        }, (st, i) -> {
            ResultSet keySet = st.getGeneratedKeys();
            if (keySet.next()) {
                return setting.withId(keySet.getLong(1));
            } else {
                return null;
            }
        }, "Could not create setting");
    }

    public Either<String, DBSetting> update(final DBSetting setting, final long conferenceId) {
        String sql = "UPDATE settings SET key = ?, hint = ?, value = ?, updated_at = ? WHERE id = ?";
        return get(setting.id, conferenceId).flatMap(dbSetting -> updateQuery(dataSource, c -> {
            PreparedStatement s = c.prepareStatement(sql);
            s.setString(1, setting.key);
            s.setString(2, setting.hint);
            s.setObject(3, toJson(setting.value));
            s.setTimestamp(4, Timestamp.from(Instant.now()));
            s.setLong(5, setting.id);
            return s;
        }, (st, i) -> i > 0 ? setting : null
        , "Could not update setting"));
    }

    public Either<String, Boolean> delete(final long id) {
        String sql = "DELETE FROM settings WHERE id = ?";
        return updateQuery(dataSource, c -> {
            PreparedStatement s = c.prepareStatement(sql);
            s.setLong(1, id);
            return s;
        }, (st, i) -> i > 0
        , "Could not delete setting");
    }

    private PGobject toJson(JsonObject value) throws SQLException {
        PGobject json = new PGobject();
        json.setType("json");
        json.setValue(gson.toJson(value));
        return json;
    }

    private static DBSetting fromResultSet(ResultSet rs, Gson gson) throws SQLException {
        return new DBSetting(rs.getLong("id"),
                rs.getString("key"),
                rs.getString("hint"),
                gson.fromJson(rs.getString("value"), JsonObject.class)
        );
    }

}
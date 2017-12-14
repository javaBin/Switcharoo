package no.javazone.switcharoo.dao;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import io.vavr.collection.List;
import io.vavr.control.Either;
import no.javazone.switcharoo.dao.model.Setting;
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

    public List<Setting> list() {
        String sql = "SELECT * FROM settings ORDER BY id";
        return query(dataSource, sql, rs -> {
            List<Setting> settings = List.empty();
            while (rs.next()) {
                settings = settings.append(fromResultSet(rs, gson));
            }
            return settings;
        }).getOrElse(List::empty);
    }

    public Either<String, Setting> get(long id) {
        String sql = "SELECT * FROM settings WHERE id = ?";
        return query(dataSource, c -> {
            PreparedStatement statement = c.prepareStatement(sql);
            statement.setLong(1, id);
            return statement;
        }, rs -> {
            if (rs.next()) {
                return fromResultSet(rs, gson);
            } else {
                return null;
            }
        }, "Could not find setting");
    }

    public Either<String, Setting> getByKey(final String key) {
        String sql = "SELECT * FROM settings WHERE key = ?";
        return query(dataSource,
            c -> {
                PreparedStatement p = c.prepareStatement(sql);
                p.setString(1, key);
                return p;
            },
            rs -> rs.next() ? fromResultSet(rs, gson) : null,
            String.format("Could not find setting with key %s", key)
        );
    }

    public Either<String, Setting> create(final Setting setting) {
        String sql = "INSERT INTO settings(key, hint, value) VALUES(?, ?, ?)";
        return updateQuery(dataSource, c -> {
            PreparedStatement s = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            s.setString(1, setting.key);
            s.setString(2, setting.hint);
            s.setObject(3, toJson(setting.value));
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

    public Either<String, Setting> update(final Setting setting) {
        String sql = "UPDATE settings SET key = ?, hint = ?, value = ?, updated_at = ? WHERE id = ?";
        return get(setting.id).flatMap(dbSetting -> updateQuery(dataSource, c -> {
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

    private static Setting fromResultSet(ResultSet rs, Gson gson) throws SQLException {
        return new Setting(rs.getLong("id"),
                rs.getString("key"),
                rs.getString("hint"),
                gson.fromJson(rs.getString("value"), JsonObject.class)
        );
    }

}
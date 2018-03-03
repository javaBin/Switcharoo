package no.javazone.switcharoo.dao;

import io.vavr.control.Either;
import no.javazone.switcharoo.dao.model.DBOverlay;

import javax.sql.DataSource;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.Instant;

import static no.javazone.switcharoo.dao.utils.DBUtils.query;
import static no.javazone.switcharoo.dao.utils.DBUtils.updateQuery;

public class OverlayDao {

    private final DataSource dataSource;

    public OverlayDao(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    public Either<String, DBOverlay> get(final long conferenceId) {
        String sql = "SELECT * FROM overlays WHERE conference_id = ?";
        return query(dataSource, c -> {
            PreparedStatement p = c.prepareStatement(sql);
            p.setLong(1, conferenceId);
            return p;
        }, rs -> {
            if (rs.next()) {
                return fromResult(rs);
            } else {
                return null;
            }
        }, "Could not find overlay for conference " + conferenceId);
    }

    public Either<String, DBOverlay> update(final DBOverlay overlay, final long conferenceId) {
        String sql = "UPDATE overlays SET enabled = ?, image = ?, placement = ?, width = ?, height = ?, updated_at = ? WHERE conference_id = ?";
        return updateQuery(dataSource, c -> {
            PreparedStatement p = c.prepareStatement(sql);
            p.setBoolean(1, overlay.enabled);
            p.setString(2, overlay.image);
            p.setString(3, overlay.placement);
            p.setString(4, overlay.width);
            p.setString(5, overlay.height);
            p.setTimestamp(6, Timestamp.from(Instant.now()));
            p.setLong(7, conferenceId);
            return p;
        }, (st, i) -> i > 0 ? overlay : null, "Could not update overlay");
    }

    private DBOverlay fromResult(ResultSet rs) throws SQLException {
        return new DBOverlay(
            rs.getBoolean("enabled"),
            rs.getString("image"),
            rs.getString("placement"),
            rs.getString("width"),
            rs.getString("height")
        );
    }
}

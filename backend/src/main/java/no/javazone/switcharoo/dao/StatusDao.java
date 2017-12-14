package no.javazone.switcharoo.dao;

import javax.sql.DataSource;

import static no.javazone.switcharoo.dao.utils.DBUtils.query;

public class StatusDao {

    private final DataSource dataSource;

    public StatusDao(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    public boolean isConnected() {
        String sql = "SELECT 1";
        return query(dataSource, sql, rs -> true).getOrElseGet(a -> false);
    }
}

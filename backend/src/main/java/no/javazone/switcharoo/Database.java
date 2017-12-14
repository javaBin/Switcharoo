package no.javazone.switcharoo;

import javax.sql.DataSource;
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.flywaydb.core.Flyway;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

class Database {

    static Logger LOG = LoggerFactory.getLogger(Database.class);

    private DataSource dataSource;

    public Database(String connectionUrl, String username, String password) {
        this.dataSource = initializeDataSource(connectionUrl, username, password);
    }

    public DataSource dataSource() {
        return dataSource;
    }

    private DataSource initializeDataSource(String connectionUrl, String username, String password) {
        LOG.info("Connecting to {}", connectionUrl);
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(connectionUrl);
        config.setUsername(username);
        config.setPassword(password);
        return new HikariDataSource(config);
    }


    public void migrate() {
        Flyway flyway = new Flyway();
        flyway.setDataSource(dataSource());
        flyway.migrate();
    }
    
}

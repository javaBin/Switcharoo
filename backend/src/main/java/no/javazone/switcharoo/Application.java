package no.javazone.switcharoo;

import com.google.gson.Gson;
import no.javazone.switcharoo.api.*;
import no.javazone.switcharoo.api.socketio.SocketIOSessions;
import no.javazone.switcharoo.config.Properties;
import no.javazone.switcharoo.dao.*;
import no.javazone.switcharoo.exception.BadRequestException;
import no.javazone.switcharoo.exception.NotFoundException;
import no.javazone.switcharoo.service.TwitterService;
import org.aeonbits.owner.ConfigFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.sql.DataSource;

import java.nio.file.Paths;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;

import static spark.Spark.*;

public class Application {

    static Logger LOG = LoggerFactory.getLogger(Application.class);

    public static void main(String[] args) throws Exception {
        Properties properties = ConfigFactory.create(Properties.class);
        Database db = new Database(properties.dbConnectionString(), properties.dbUsername(), properties.dbPassword());
        db.migrate();

        Authentication auth = new Authentication(properties.auth0Secret(), properties.auth0issuer());

        DataSource dataSource = db.dataSource();
        ScheduledExecutorService executor = Executors.newSingleThreadScheduledExecutor();
        Gson gson = new Gson();

        ConferenceDao conferences = new ConferenceDao(dataSource);
        CssDao css = new CssDao(dataSource);
        ServiceDao services = new ServiceDao(dataSource);
        SettingsDao settings = new SettingsDao(dataSource, gson);
        SlidesDao slides = new SlidesDao(dataSource);
        StatusDao status = new StatusDao(dataSource);
        TwitterService twitter = new TwitterService(executor, settings, services, properties);
        SocketIOSessions sessions = new SocketIOSessions();

        List<HttpService> httpServices = Arrays.asList(
            new Conferences(conferences, auth),
            new Settings(settings, auth),
            new Slides(slides, auth),
            new Csses(css, auth),
            new Services(services, auth),
            new Tweets(twitter),
            new Program(executor),
            new Data(slides, twitter),
            new Status(status),
            new SocketIO(sessions),
            new FileUpload(properties.filesUploadDir()),
            new Static("/admin/*", Paths.get(properties.filesFrontendDir(), "admin")),
            new Static("/uploads/*", Paths.get(properties.filesUploadDir())),
            new Static("/*", Paths.get(properties.filesFrontendDir(), "public"))
        );

        Ws ws = new Ws(sessions);
        webSocket("/socket.io/*", ws);

        exception(BadRequestException.class, (e, req, res) -> {
            res.status(400);
            res.body(e.reason);
        });
        exception(NotFoundException.class, (e, req, res) -> {
            res.status(404);
            res.body(e.reason);
        });

        redirect.get("/admin", "/admin/");

        httpServices.forEach(s -> s.register(gson));
    }
}

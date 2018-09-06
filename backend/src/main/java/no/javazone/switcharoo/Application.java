package no.javazone.switcharoo;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.TypeAdapter;
import com.google.gson.stream.JsonReader;
import com.google.gson.stream.JsonWriter;
import io.vavr.gson.VavrGson;
import no.javazone.switcharoo.api.*;
import no.javazone.switcharoo.api.socketio.WSSessions;
import no.javazone.switcharoo.config.Properties;
import no.javazone.switcharoo.dao.*;
import no.javazone.switcharoo.dao.model.DBConference;
import no.javazone.switcharoo.exception.BadRequestException;
import no.javazone.switcharoo.exception.NotFoundException;
import no.javazone.switcharoo.service.ProgramService;
import no.javazone.switcharoo.service.TwitterService;
import org.aeonbits.owner.ConfigFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import spark.Request;

import javax.sql.DataSource;

import java.io.IOException;
import java.nio.file.Paths;
import java.time.ZonedDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;

import static no.javazone.switcharoo.Util.parseLong;
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
        GsonBuilder gsonBuilder = new GsonBuilder();
        gsonBuilder.setDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
        gsonBuilder.registerTypeAdapter(ZonedDateTime.class, new TypeAdapter<ZonedDateTime>() {
            @Override
            public void write(JsonWriter out, ZonedDateTime value) throws IOException {
                out.value(value.toString());
            }

            @Override
            public ZonedDateTime read(JsonReader in) throws IOException {
                return ZonedDateTime.parse(in.nextString());
            }
        }).enableComplexMapKeySerialization();
        VavrGson.registerAll(gsonBuilder);
        Gson gson = gsonBuilder.create();

        ConferenceDao conferences = new ConferenceDao(dataSource);
        CssDao css = new CssDao(dataSource);
        ServiceDao services = new ServiceDao(dataSource);
        SettingsDao settings = new SettingsDao(dataSource, gson);
        SlidesDao slides = new SlidesDao(dataSource);
        StatusDao status = new StatusDao(dataSource);
        OverlayDao overlays = new OverlayDao(dataSource);
        TwitterService twitter = new TwitterService(executor, settings, properties, conferences);
        ProgramService program = new ProgramService(executor, settings, properties, gson);
        WSSessions sessions = new WSSessions();

        List<HttpService> httpServices = Arrays.asList(
            new Auth(auth),
            new Program(program),
            new Conferences(conferences, auth),
            new Settings(settings, auth),
            new Slides(slides, auth),
            new Csses(css, conferences, auth),
            new Services(services, auth),
            new Overlays(overlays),
            new Tweets(twitter),
            new Data(slides, conferences, overlays, services, twitter, program),
            new Status(status),
            new FileUpload(properties.filesUploadDir()),
            new Static("/admin/*", Paths.get(properties.filesFrontendDir(), "admin")),
            new Static("/conference/:id/*", Paths.get(properties.filesFrontendDir(), "public")),
            new Static("/uploads/*", Paths.get(properties.filesUploadDir())),
            new Static("/display/*", Paths.get(properties.filesFrontendDir(), "public"))
        );

        exception(BadRequestException.class, (e, req, res) -> {
            LOG.warn("BadRequest: {}", e.reason);
            res.status(400);
            res.body(e.reason);
        });
        exception(NotFoundException.class, (e, req, res) -> {
            res.status(404);
            res.body(e.reason);
        });


        Ws ws = new Ws(sessions);
        webSocket("/websocket", ws);
        redirect.get("/admin", "/admin/");
        redirect.get("/display", "/display/");
        redirect.get("/", "/display/");
        httpServices.forEach(s -> s.register(gson));

        before("/conferences/:conference/*", (req, res) -> setConference(req, conferences));
        afterAfter((req, res) -> MDC.clear());
    }

    public static void setConference(Request req, ConferenceDao conferences) {
        Long conferenceId = parseLong(req.params(":conference")).getOrElseThrow(BadRequestException::new);
        DBConference conference = conferences.get(conferenceId).getOrElseThrow(NotFoundException::new);
        req.attribute("conference", conference.id);
        MDC.put("conference", Long.toString(conference.id));
    }
}

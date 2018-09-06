package no.javazone.switcharoo.service;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.TypeAdapter;
import com.google.gson.stream.JsonReader;
import com.google.gson.stream.JsonWriter;
import io.vavr.collection.List;
import io.vavr.control.Option;
import io.vavr.control.Try;
import io.vavr.gson.VavrGson;
import no.javazone.switcharoo.Application;
import no.javazone.switcharoo.config.Properties;
import no.javazone.switcharoo.dao.SettingsDao;
import no.javazone.switcharoo.service.domain.Event;
import no.javazone.switcharoo.service.domain.Slot;
import no.javazone.switcharoo.service.domain.SlotItem;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import org.aeonbits.owner.ConfigFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.time.ZonedDateTime;
import java.util.Comparator;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

public class ProgramService {

    static Logger LOG = LoggerFactory.getLogger(ProgramService.class);

    private final SettingsDao settings;
    private final Properties properties;
    private final Gson gson;
    private final OkHttpClient client;

    private List<Slot> sessions = List.empty();

    public ProgramService(ScheduledExecutorService executor, SettingsDao settings, Properties properties, Gson gson) {
        this.settings = settings;
        this.properties = properties;
        this.gson = gson;
        executor.scheduleAtFixedRate(getProgram(), 1, 60 * 1, TimeUnit.SECONDS);
        client = new OkHttpClient();
    }

    public List<Slot> sessions() {
        return sessions;
    }

    public Option<Slot> getSlot(ZonedDateTime timestamp) {
        return sessions.find(slot -> {
            if (isBetween(timestamp, slot.start, slot.end)) {
                return true;
            }

            if (timestamp.isBefore(slot.start)) {
                return true;
            }

            return false;
        });
    }

    private Runnable getProgram() {
        System.out.println(properties.programUrl());
        return () -> {
            Request request = new Request.Builder()
                .url(properties.programUrl())
                .build();

            sessions = Try.of(() -> client.newCall(request).execute())
                .onFailure(e -> LOG.error("Error fetching program", e))
                .mapTry(res -> res.body().string())
                .onFailure(e -> LOG.error("Error getting program body", e))
                .mapTry(body -> gson.fromJson(body, Event.class))
                .onFailure(k -> LOG.error("Error decoding program body", k))
                .toOption()
                .map(this::group)
                .getOrElse(List.empty());
        };
    }

    private List<Slot> group(Event event) {
        List<Slot> slots = event.sessions
            .filter(s -> "presentation".equals(s.format) && "60".equals(s.length))
            .sortBy((s) -> s.startTimeZulu)
            .map(s -> new Slot(s.startTimeZulu, s.endTimeZulu))
            .distinct();

        event.sessions.forEach(session -> slots.forEach(slot -> {
            if (isBetween(session.startTimeZulu, slot.start, slot.end)) {
                if ("presentation".equals(session.format)) {
                    slot.sessions.add(new SlotItem(session.title, session.speakers.stream().map(s -> s.name).collect(Collectors.joining(", ")), session.room.replace("Room ", "")));
                } else {
                    SlotItem lightningTalks = new SlotItem("Lightning talks", "Various speakers", session.room.replace("Room ", ""));
                    if (!slot.sessions.contains(lightningTalks)) {
                        slot.sessions.add(lightningTalks);
                    }
                }
            }
        }));
        slots.forEach(slot -> slot.sessions.sort(Comparator.comparing(s -> s.room)));
        System.out.println(gson.toJson(slots));

        return slots;
    }

    private boolean isBetween(ZonedDateTime date, ZonedDateTime start, ZonedDateTime end) {
        boolean isAfter = date.isAfter(start);
        boolean isBefore = date.isBefore(end);
        boolean isEqual = date.isEqual(start);
        return (isAfter || isEqual) && isBefore;
    }

    public static void main(String[] args) throws InterruptedException {
        Properties properties = ConfigFactory.create(Properties.class);
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
        })
        .enableComplexMapKeySerialization();
        VavrGson.registerAll(gsonBuilder);
        Gson gson = gsonBuilder.create();
        ProgramService program = new ProgramService(executor, null, properties, gson);
    }
}

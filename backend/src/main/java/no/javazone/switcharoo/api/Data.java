package no.javazone.switcharoo.api;

import com.google.gson.Gson;
import io.vavr.collection.List;
import no.javazone.switcharoo.Application;
import no.javazone.switcharoo.api.mapper.ConferenceMapper;
import no.javazone.switcharoo.api.mapper.OverlayMapper;
import no.javazone.switcharoo.api.mapper.SlideMapper;
import no.javazone.switcharoo.api.model.Overlay;
import no.javazone.switcharoo.api.model.ProgramSlide;
import no.javazone.switcharoo.api.model.PublicData;
import no.javazone.switcharoo.api.model.Slide;
import no.javazone.switcharoo.api.model.Tweet;
import no.javazone.switcharoo.api.model.TwitterSlide;
import no.javazone.switcharoo.dao.ConferenceDao;
import no.javazone.switcharoo.dao.OverlayDao;
import no.javazone.switcharoo.dao.ServiceDao;
import no.javazone.switcharoo.dao.SlidesDao;
import no.javazone.switcharoo.service.ProgramService;
import no.javazone.switcharoo.service.TwitterService;
import no.javazone.switcharoo.service.domain.Slot;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;

import static spark.Spark.get;

public class Data implements HttpService {

    static Logger LOG = LoggerFactory.getLogger(Data.class);

    private final SlidesDao slides;
    private final ConferenceDao conferences;
    private final OverlayDao overlays;
    private final TwitterService twitter;
    private final ServiceDao services;
    private final ProgramService program;

    public Data(SlidesDao slides, ConferenceDao conferences, OverlayDao overlays, ServiceDao services, TwitterService twitter, ProgramService program) {
        this.slides = slides;
        this.conferences = conferences;
        this.overlays = overlays;
        this.services = services;
        this.twitter = twitter;
        this.program = program;
    }

    @Override
    public void register(Gson gson) {
        get("/data", (req, res) -> gson.toJson(conferences.list().map(ConferenceMapper::fromDb)));

        get("/data/:conference", (req, res) -> {
            Application.setConference(req, conferences);
            List<Object> data = List.empty();
            long conference = req.attribute("conference");
            data = data.appendAll(slides.listVisible(conference).map(SlideMapper::fromDb).filter(this::knownTypes));
            if (isTwitterEnabled(conference)) {
                List<Tweet> t = twitter.tweets(conference);
                if (t.size() > 0) {
                    data = data.append(new TwitterSlide(t));
                }
            }

            if (isProgramEnabled(conference)) {
                ZonedDateTime time = ZonedDateTime.parse("2018-09-12T08:01:00Z");//ZonedDateTime.now();
                Slot slot = program.getSlot(time)
                    .getOrNull();

                if (slot != null) {
                    String heading = time.isBefore(slot.start) ? "Next up" : "Right now";
                    data = data.append(new ProgramSlide(heading, slot.sessions));
                }
            }

            Overlay overlay = overlays.get(req.attribute("conference")).map(OverlayMapper::fromDb).getOrElse((Overlay)null);

            res.type("application/json");
            return gson.toJson(new PublicData(data, overlay));
        });
    }

    private boolean knownTypes(Slide slide) {
        return "text".equals(slide.type) || "image".equals(slide.type) || "video".equals(slide.type) || "tweets".equals(slide.type) || "program".equals(slide.type);
    }

    private boolean isProgramEnabled(long conference) {
        return services.getByKey("program-enabled", conference)
            .map(value -> value.value)
            .getOrElseGet(error -> {
                LOG.error(error);
                return false;
            });
    }

    private boolean isTwitterEnabled(long conference) {
        return services.getByKey("twitter-enabled", conference)
            .map(value -> value.value)
            .getOrElseGet(error -> {
                LOG.error(error);
                return false;
            });
    }
}

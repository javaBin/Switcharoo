package no.javazone.switcharoo.api;

import com.google.gson.Gson;
import io.vavr.collection.List;
import no.javazone.switcharoo.Application;
import no.javazone.switcharoo.api.mapper.ConferenceMapper;
import no.javazone.switcharoo.api.mapper.OverlayMapper;
import no.javazone.switcharoo.api.mapper.SlideMapper;
import no.javazone.switcharoo.api.model.Overlay;
import no.javazone.switcharoo.api.model.PublicData;
import no.javazone.switcharoo.api.model.Tweet;
import no.javazone.switcharoo.api.model.TwitterSlide;
import no.javazone.switcharoo.dao.ConferenceDao;
import no.javazone.switcharoo.dao.OverlayDao;
import no.javazone.switcharoo.dao.ServiceDao;
import no.javazone.switcharoo.dao.SlidesDao;
import no.javazone.switcharoo.service.TwitterService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static spark.Spark.get;

public class Data implements HttpService {

    static Logger LOG = LoggerFactory.getLogger(Data.class);

    private final SlidesDao slides;
    private final ConferenceDao conferences;
    private final OverlayDao overlays;
    private final TwitterService twitter;
    private final ServiceDao services;

    public Data(SlidesDao slides, ConferenceDao conferences, OverlayDao overlays, ServiceDao services, TwitterService twitter) {
        this.slides = slides;
        this.conferences = conferences;
        this.overlays = overlays;
        this.services = services;
        this.twitter = twitter;
    }

    @Override
    public void register(Gson gson) {
        get("/data", (req, res) -> gson.toJson(conferences.list().map(ConferenceMapper::fromDb)));

        get("/data/:conference", (req, res) -> {
            Application.setConference(req, conferences);
            List<Object> data = List.empty();
            long conference = req.attribute("conference");
            data = data.appendAll(slides.listVisible(conference).map(SlideMapper::fromDb));
            if (isTwitterEnabled(conference)) {
                List<Tweet> t = twitter.tweets(conference);
                if (t.size() > 0) {
                    data = data.append(new TwitterSlide(t));
                }
            }

            Overlay overlay = overlays.get(req.attribute("conference")).map(OverlayMapper::fromDb).getOrElse((Overlay)null);

            res.type("application/json");
            return gson.toJson(new PublicData(data, overlay));
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

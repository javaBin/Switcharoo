package no.javazone.switcharoo.api;

import com.google.gson.Gson;
import io.vavr.collection.List;
import no.javazone.switcharoo.Application;
import no.javazone.switcharoo.api.mapper.SlideMapper;
import no.javazone.switcharoo.api.model.PublicData;
import no.javazone.switcharoo.api.model.Tweet;
import no.javazone.switcharoo.api.model.TwitterSlide;
import no.javazone.switcharoo.dao.ConferenceDao;
import no.javazone.switcharoo.dao.SlidesDao;
import no.javazone.switcharoo.service.TwitterService;

import static spark.Spark.get;

public class Data implements HttpService {

    private final SlidesDao slides;
    private final ConferenceDao conferences;
    private final TwitterService twitter;

    public Data(SlidesDao slides, ConferenceDao conferences, TwitterService twitter) {
        this.slides = slides;
        this.conferences = conferences;
        this.twitter = twitter;
    }

    @Override
    public void register(Gson gson) {
        get("/data/:conference", (req, res) -> {
            Application.setConference(req, conferences);
            List<Object> data = List.empty();
            data = data.appendAll(slides.listVisible(req.attribute("conference")).map(SlideMapper::fromDb));
            List<Tweet> t = twitter.tweets();
            if (t.size() > 0) {
                data = data.append(new TwitterSlide(t));
            }

            res.type("application/json");
            return gson.toJson(new PublicData(data));
        });
    }
}

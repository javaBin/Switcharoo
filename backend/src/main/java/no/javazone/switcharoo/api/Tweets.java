package no.javazone.switcharoo.api;

import com.google.gson.Gson;
import no.javazone.switcharoo.service.TwitterService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static spark.Spark.after;
import static spark.Spark.get;

public class Tweets implements HttpService {

    static Logger LOG = LoggerFactory.getLogger(Tweets.class);
    private final TwitterService twitter;

    public Tweets(TwitterService twitter) {
        this.twitter = twitter;
    }

    @Override
    public void register(Gson gson) {
        get("/twitter", (req, res) -> twitter.tweets(), gson::toJson);
        after("/twitter", (req, res) -> res.type("application/json"));
    }
}

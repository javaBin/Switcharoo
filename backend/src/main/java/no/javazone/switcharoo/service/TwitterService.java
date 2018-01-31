package no.javazone.switcharoo.service;

import io.vavr.collection.List;
import io.vavr.control.Try;
import no.javazone.switcharoo.api.model.Tweet;
import no.javazone.switcharoo.config.Properties;
import no.javazone.switcharoo.dao.ServiceDao;
import no.javazone.switcharoo.dao.SettingsDao;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import twitter4j.Query;
import twitter4j.Status;
import twitter4j.Twitter;
import twitter4j.TwitterFactory;
import twitter4j.conf.ConfigurationBuilder;

import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class TwitterService {

    static Logger LOG = LoggerFactory.getLogger(TwitterService.class);
    private final SettingsDao settings;
    private final ServiceDao services;
    private Twitter twitter;
    private List<Tweet> tweets = List.empty();

    public TwitterService(ScheduledExecutorService executor, SettingsDao settings, ServiceDao services, Properties properties) {
        executor.scheduleAtFixedRate(getTweets(), 1, 10 * 60, TimeUnit.SECONDS);
        this.settings = settings;
        this.services = services;
        this.twitter = getTwitterClient(
                properties.twitterConsumerKey(),
                properties.twitterConsumerSecret(),
                properties.twitterAccessToken(),
                properties.twitterAccessTokenSecret()
        );
    }

    public List<Tweet> tweets() {
        return this.tweets;
    }

    private Twitter getTwitterClient(String consumerKey, String consumerSecret, String accessToken, String accessTokenSecret) {
        ConfigurationBuilder config = new ConfigurationBuilder();
        config.setOAuthConsumerKey(consumerKey)
            .setOAuthConsumerSecret(consumerSecret)
            .setOAuthAccessToken(accessToken)
            .setOAuthAccessTokenSecret(accessTokenSecret);
        TwitterFactory factory = new TwitterFactory(config.build());
        return factory.getInstance();
    }

    private Runnable getTweets() {
        return () -> {
            if (isTwitterEnabled()) {
                tweets = settings.getByKey("twitter-search")
                    .map(value -> value.value.get("value").getAsString())
                    .flatMap(searchTerm -> {
                        LOG.info(String.format("Fetching new tweets: %s", searchTerm));
                        Query query = new Query(String.format("%s +exclude:retweets", searchTerm))
                            .resultType(Query.ResultType.recent)
                            .count(4);
                        return Try.of(() -> twitter.search(query)).toEither().mapLeft(e -> e.getMessage());
                    })
                    .map(result -> List.ofAll(result.getTweets()).map(this::mapTweet))
                    .getOrElseGet(error -> {
                        LOG.error(error);
                        return List.empty();
                    });
                LOG.info(String.format("New tweets: %s", tweets.toString()));
            } else {
                LOG.info("Twitter is not enabled, NOT fetching new tweets");
            }
        };
    }

    private Tweet mapTweet(Status status) {
        return new Tweet(
            status.getText(),
            status.getUser().getName(),
            status.getUser().getOriginalProfileImageURL(),
            status.getUser().getScreenName()
        );
    }

    private boolean isTwitterEnabled() {
        return services.getByKey("twitter-enabled")
            .map(value -> value.value)
            .getOrElseGet(error -> {
                LOG.error(error);
                return false;
            });
    }
}

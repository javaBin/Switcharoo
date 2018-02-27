package no.javazone.switcharoo.api.model;

import io.vavr.collection.List;

public class TwitterSlide {
    public final String type = "tweets";
    public final List<Tweet> tweets;

    public TwitterSlide(List<Tweet> tweets) {
        this.tweets = tweets;
    }
}

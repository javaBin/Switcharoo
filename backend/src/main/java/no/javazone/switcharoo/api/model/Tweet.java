package no.javazone.switcharoo.api.model;

public class Tweet {
    public final String text;
    public final String user;
    public final String image;
    public final String handle;

    public Tweet(String text, String user, String image, String handle) {
        this.text = text;
        this.user = user;
        this.image = image;
        this.handle = handle;
    }
}

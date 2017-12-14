package no.javazone.switcharoo.config;

import org.aeonbits.owner.Config;

@Config.Sources({
        "file:~/.switcharoo.config"
})
public interface Properties extends Config {

    @Key("twitter.consumerKey")
    String twitterConsumerKey();

    @Key("twitter.consumerSecret")
    String twitterConsumerSecret();

    @Key("twitter.accessToken")
    String twitterAccessToken();

    @Key("twitter.accessTokenSecret")
    String twitterAccessTokenSecret();

    @Key("db.connectionString")
    String dbConnectionString();

    @Key("db.username")
    String dbUsername();

    @Key("db.password")
    String dbPassword();

    @Key("files.uploadDir")
    String filesUploadDir();

    @Key("files.frontendDir")
    String filesFrontendDir();

    @Key("program.url")
    String programUrl();

    @Key("auth0.secret")
    String auth0Secret();

    @Key("auth0.issuer")
    String auth0issuer();

}

var cron = require('cron').CronJob;
var config = require('../config');
var twit = require('twit');
var Setting = require('../models').Setting;

var Twitter = new twit(config.twitter);

var current_tweets = [];

var cronPattern = config.twitter.cronPattern || "0 */10 * * * *";

var job = new cron(cronPattern, getTweets);

function getTweets(complete) {
    Twitter.get('search/tweets', {
        q: 'javazone exclude:retweets',
        count: 4,
        result_type: 'recent'
    }, function(err, data, response) {
        if (err) {
            console.error('Error fetching tweets:');
            console.error(err);
            return;
        }

        console.log('Got new tweets from twitter');

        data = data.statuses.map(function(tweet) {
            return {
                text: tweet.text,
                user: tweet.user.name,
                image: tweet.user.profile_image_url.replace('_normal', ''),
                handle: tweet.user.screen_name
            };
        });


        // Seems we sometimes get more than 5 tweets, so we limit it to 5 here
        current_tweets = data.slice(0, 4);

        if (complete)
            complete();
    });
}

function get() {
    getTweets(function() {
        job.start();
    });
}

function tweets(res) {
    Setting.findOne({
        where: {key: 'twitter-enabled'}
    }).then(function(setting) {
        if (setting && !setting.get('value'))
            res.json({
                tweets: []
            });
        else
            res.json({
                tweets: current_tweets
            });
    });
}

function status() {
    var tweets = current_tweets.length;
    if (tweets === 0) {
        return {
            service: 'twitter',
            error: 'No tweets found',
            statusCode: 500
        };
    }

    return {
        service: 'twitter',
        statusCode: 200
    };
}

function asJson() {
    return Setting.findOne({
            where: {key: 'twitter-enabled'}
        })
        .then((setting) => {
            if (setting && !setting.value) {
                return [];
            }

            return {
                type: 'tweets',
                tweets: current_tweets
            };
        });
}

module.exports = {
    get: get,
    tweets: tweets,
    status: status,
    asJson: asJson
};

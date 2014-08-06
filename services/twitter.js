var cron = require('cron').CronJob;
var config = require('../config');
var twit = require('twit');

var Twitter = new twit(config.twitter);

var current_tweets = [];

var cronPattern = config.twitter.cronPattern || "0 */10 * * * *";

var job = new cron(cronPattern, getTweets);

function getTweets(complete) {
	Twitter.get('search/tweets', {q: 'javazone #javazone', count: 5, result_type: 'mixed'}, function(err, data, response) {
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
				image: tweet.user.profile_image_url.replace('_normal', '')
			};
		});

		current_tweets = data;

		if (complete)
			complete();
	});
}

function get() {
	getTweets(function() {
		job.start();
	});
}

function tweets() {
	return current_tweets;
}

module.exports = {
	get: get,
	tweets: tweets
};
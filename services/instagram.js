var cron = require('cron').CronJob;
var config = require('../config');
var Instagram = require('instagram-node-lib');
var _ = require('lodash');

Instagram.set('client_id', config.instagram.client_id);
Instagram.set('client_secret', config.instagram.client_secret);

var current_media = [];

var cronPattern = config.twitter.cronPattern || "0 */10 * * * *";

var job = new cron(cronPattern, getMedia);

function getMedia(complete) {
	Instagram.tags.recent({
		name: 'javazone',
		count: 16,
		complete: function(data) {
			console.log('Got new data from instagram');
			data = _.chain(data).groupBy(function(element, index) {
				return Math.floor(index / 2);
			}).map(function(array) {
				return {
					'first': array[0].images.low_resolution.url,
					'second': array[1].images.low_resolution.url
				};
			}).value();
			
			current_media = data;

			if (complete)
				complete();
		},
		error: function(errMessage) {
			console.error('Error getting media from instagram: ');
			console.error(errMessage);
		}
	});
}

function get() {
	getMedia(function() {
		job.start();
	});
}

function media() {
	return current_media;
}

module.exports = {
	get: get,
	media: media
};
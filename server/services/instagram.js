var cron = require('cron').CronJob;
var config = require('../config');
var Instagram = require('instagram-node-lib');
var _ = require('lodash');
var Setting = require('../models/setting');

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

function media(res) {
    Setting.findOne({key: 'instagram-enabled'}, function(err, setting) {
        console.log('Returning instagram media');
        if (err || !setting || !setting.value)
            res.json({media: []});
        else
            res.json({media: current_media});
    });
}

function status() {
	var media = current_media.length;
	if (media === 0) {
		return {
			service: 'instagram',
			error: 'No media found',
			statusCode: 500
		};
	}

	return {
		service: 'instagram',
		statusCode: 200
	};
}

function asJson() {
    return Setting.findOne({key: 'instagram-enabled'})
        .then((err, setting) => {
            if (err || !setting || !setting.value) {
                return [];
            }
            return current_media;
        });
}

module.exports = {
    get: get,
    media: media,
	  status: status,
    asJson, asJson
};
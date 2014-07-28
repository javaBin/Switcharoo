var cron = require('cron').CronJob;
var config = require('./configuration').program;
var request = require('request');
var moment = require('moment');

var cronPattern = config.cronPattern || '0 */10 * * * *';

var current_program = null;

var date = moment("2013-09-11T15:40:00Z");

var job = new cron(cronPattern, getProgram);

function getProgram(complete) {
	request(config.url, function(error, response, body) {
		if (error)
			return console.error(error);

		body = JSON.parse(body);

		if (!Array.isArray(body))
			return console.error("Response from \"" + config.url + "\" was not an array: " + body);

		current_program = body
			.filter(function(talk) {
				return moment(talk.start).isBefore(date) && moment(talk.stop).isAfter(date);
			}).sort(function(a, b) {
				return a.room > b.room;
			});

		if (complete)
			complete();
	});
}

function get() {
	getProgram(function() {
		job.start();
	});
}

function program() {
	return current_program;
}

module.exports = {
	get: get,
	program: program
};
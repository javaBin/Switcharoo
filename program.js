var cron = require('cron').CronJob;
var config = require('./configuration').program;
var request = require('request');

var cronPattern = config.cronPattern || '0 */1 * * * *';

var current_program = null;

var job = new cron(cronPattern, getProgram);

function getProgram(complete) {
	request(config.url, function(error, response, body) {
		if (error)
			return console.error(error);

		body = JSON.parse(body);

		if (!Array.isArray(body))
			return console.error("Response from \"" + config.url + "\" was not an array: " + body);

		current_program = body.filter(function(talk) {
			return talk.room === 'Room 4';
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
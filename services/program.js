var cron = require('cron').CronJob;
var config = require('../config').program;
var request = require('request');
var moment = require('moment');

var cronPattern = config.cronPattern || '0 */10 * * * *';

var current_program = null;

var date = moment("2013-09-11T11:41:00Z");

var job = new cron(cronPattern, getProgram);

function getProgram(complete) {
	request(config.url, function(error, response, body) {
		if (error)
			return console.error(error);

		try {
			body = JSON.parse(body);
		} catch (e) {
			console.error('Error trying to parse response from program:');
			console.error(e);
		}

		if (!Array.isArray(body))
			return console.error("Response from \"" + config.url + "\" was not an array: " + body);

		console.log('Got new program from javazone server');

		var program = body.filter(function(talk) {
			return moment(talk.start).isBefore(date) && moment(talk.stop).isAfter(date) && talk.format == 'presentation';
		}).map(function(talk) {
			return {
				room: talk.room.replace("Room ", ""),
				title: talk.title,
				format: talk.format,
				speakers: talk.speakers.map(function(speaker) { return speaker.name; }).join(', '),
				start: talk.start,
				stop: talk.stop
			};
		}).sort(function(a, b) {
			return a.room > b.room;
		});

		var start = moment(program[0].start);
		var stop = moment(program[0].stop);

		var currentLightningTalk = first(body, function(talk) {
			var talkStart = moment(talk.start);
			var talkStop = moment(talk.stop);
			return (talkStart.isAfter(start) && talkStart.isBefore(stop)) || (talkStop.isAfter(start) && talkStop.isBefore(stop));
		});

		if (currentLightningTalk)
			program.push({room: currentLightningTalk.room.replace("Room ", ""), title: 'Lightning Talks'})

		current_program = program;

		if (complete)
			complete();
	});
}

function first(array, fn) {
	var length = array.length;
	for (var i = 0; i < length; i++) {
		if (fn(array[i]))
			return array[i];
	}

	return undefined;
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
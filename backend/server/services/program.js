var cron = require('cron').CronJob;
var config = require('../config').program;
var request = require('request');
var moment = require('moment');
var _ = require('lodash');
var Service = require('../models').Service;
const log = require('../log');

var cronPattern = config.cronPattern || '0 */10 * * * *';

var current_program = {};

var date = moment("2013-09-11T14:50:00Z");

var job = new cron(cronPattern, getProgram);

function createSlots(memo, current) {
	var timestamp = current.timestamp;
	if (current.format === 'presentation') {
		var slot = memo[timestamp] || [];
		slot.push(current);
		memo[timestamp] = slot;
	} else {
		timestamp = _.chain(Object.keys(memo))
			.filter(function(slot) {
				return slot <= timestamp;
			})
			.last()
			.value();
		var slot = memo[timestamp];
		slot.push(current);
		memo[timestamp] = slot;
	}

	return memo;
}

function removeWorkshops(d) {
	return d.format !== 'workshop' && d.rom !== null && d.starter !== null;
}

function parseSession(d) {
    return {
        room: d.room.replace('Room ', ''),
        title: d.title,
        format: d.format,
        speakers: _.pluck(d.speakers, 'name').join(', '),
        start: d.startTimeZulu,
        stop: d.endTimeZulu,
        timestamp: new Date(d.startTimeZulu).getTime(),
        names: _.pluck(d.speakers, 'name').join(', ')
    };
};

function groupSessions(data) {
	return _.chain(data)
		.filter(removeWorkshops)
		.map(parseSession)
		.sortBy(comparator('format'))
		.sortBy('start')
		.reduce(createSlots, {})
		.value();
}

// Stolen from javazone frontend. Dunno how it works, so I don't dare to touch it :)
function comparator(param, compare_depth) {
    compare_depth = compare_depth || 10;
    return function (item) {
         return String.fromCharCode.apply(String,
            _.map(item[param].slice(0, compare_depth).split(""), function (c) {
                return 0xffff - c.charCodeAt();
            })
        );
    };
}

function getProgram(complete) {
	request(config.url, function(error, response, body) {
		if (error)
			return log.error(error);

		try {
			body = JSON.parse(body);
		} catch (e) {
			log.error('Error trying to parse response from program:');
			log.error(e);
			return;
		}

		if (!Array.isArray(body.sessions))
		  return log.error("Response from \"" + config.url + "\" was not an array: " + JSON.stringify(body));

		log.info('Got new program from javazone server');

		current_program = groupSessions(body.sessions);
		if (complete)
			complete();
	});
}

function get() {
	getProgram(function() {
		job.start();
	});
}

function now() {
	var now = new moment();
	log.info('Now: ' + now);
	return now;
}

function getSlotForTimestamp(time) {
	log.info('Returning program for: ' + time);
	var timestamps = Object.keys(current_program).sort();
	if (time < timestamps[0])
		return {"heading": "Next", "presentations": current_program[timestamps[0]], type: 'program'};

	var timestamp = _.chain(timestamps)
		.filter(function(slot) {
			return slot <= time
		}).last().value();
	var end = new moment(parseInt(timestamp)).add('hours', 1);
	if (time > end) {
		var index = timestamps.indexOf(timestamp);
		return timestamps.length > index
			? {"heading": "Next", "presentations": current_program[timestamps[index + 1]], type: 'program'}
			: {"heading": "No presentations at the moment", "presentations": [], type: 'program'};
	}

	return {"heading": "Now", "presentations": current_program[timestamp], type: 'program'};
}

function program(all, res) {
  Service.findOne({where: {key: 'program-enabled'}}).then(function(service) {
        const jsonService = service.toJSON();
        if (!jsonService.value) {
            res.json({heading: 'off'});
            return;
        }

        if (all) {
            res.json(current_program);
            return;
        }

        if (Object.keys(current_program).length === 0) {
            res.json({"heading": "No presentations at the moment"});
            return;
        }

        var timestamp = now();
        var slot = getSlotForTimestamp(timestamp);
        var presentations = _(slot.presentations).reduce(function(memo, cur) {
            cur.format === 'presentation'
                ? memo[0].push(cur)
                : memo[1].push(cur);
            return memo;
        }, [[], []]);
        if (presentations[1].length > 0)
            presentations[0].push({room: presentations[1][0].room, title: 'Lightning Talks'});

        slot.presentations = _.sortBy(presentations[0], 'room');
        res.json(slot);
    });

}

function status() {
	var keys = Object.keys(current_program);
	if (keys.length === 0) {
		return {
			service: 'program',
			error: 'Something wrong with the program',
			statusCode: 500
		};
	}

	return {
		service: 'program',
		slots: keys.length,
		statusCode: 200
	};
}

function asJson() {
    return Service.findOne({where: {key: 'program-enabled'}})
        .then((service) => {
            const jsonService = service.toJSON();
            if (!jsonService.value) {
                return [];
            }
            if (Object.keys(current_program).length === 0) {
                return {heading: "No presentations at this moment"};
            }
            var timestamp = now();
            var slot = getSlotForTimestamp(timestamp);
            var presentations = _(slot.presentations).reduce(function(memo, cur) {
                cur.format === 'presentation'
                    ? memo[0].push({room: cur.room, title: cur.title, speakers: cur.speakers})
                    : memo[1].push(cur);
                return memo;
            }, [[], []]);
            if (presentations[1].length > 0) {
                var lightningTalks = _.groupBy(presentations[1], 'room');
                Object.keys(lightningTalks).forEach(function(room) {
                    presentations[0].push({
                        room: room,
                        title: 'Lightning Talks',
                        speakers: 'Multiple Speakers'
                    });
                });
            }

            slot.presentations = _.sortBy(presentations[0], 'room');
            return slot;
        });
}

module.exports = {
    get: get,
    program: program,
    status: status,
    asJson: asJson
};

var cron = require('cron').CronJob;
var config = require('../config').program;
var request = require('request');
var moment = require('moment');
var _ = require('lodash');
var Setting = require('../models/setting');

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
        room: d.rom.replace('Room ', ''),
        title: d.tittel,
        format: d.format,
        speakers: _.pluck(d.foredragsholdere, 'navn').join(', '),
        start: d.starter,
        stop: d.stopper,
        timestamp: new Date(d.starter).getTime(),
        names: _.pluck(d.foredragsholdere, 'navn').join(', ')
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
			return console.error(error);

		try {
			body = JSON.parse(body);
		} catch (e) {
			console.error('Error trying to parse response from program:');
			console.error(e);
			return;
		}

		if (!Array.isArray(body))
			return console.error("Response from \"" + config.url + "\" was not an array: " + body);

		console.log('Got new program from javazone server');

		current_program = groupSessions(body);
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
	console.log('Now: ' + now);
	return now;
}

function getSlotForTimestamp(time) {
	console.log('Returning program for: ' + time);
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
    Setting.findOne({key: 'program-enabled'}, function(err, setting) {
        if (err || !setting || !setting.value) {
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
    return Setting.findOne({key: 'program-enabled'})
        .then((setting) => {
            if (!setting || !setting.value) {
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

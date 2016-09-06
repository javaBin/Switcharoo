var cron = require('cron').CronJob;
var config = require('../config').votes;
var Setting = require('../models/setting');
var request = require('request');

var cronPattern = config.cronPattern || '0 */10 * * * *';

var job = new cron(cronPattern, getVotes);

var votes = -1;

function getVotes(complete) {
    request(config.url, function(error, response, body) {
        if (error)
            return console.error(error);

        try {
            body = JSON.parse(body);
        } catch (e) {
            console.error('Error trying to parse response from votes');
            console.error(e);
            return undefined;
        }

        if (!body.votes) {
            return undefined;
        }
        votes = body.votes;
        console.log('Got new votes from backend');

        if (complete)
            complete();
    });
}

function get() {
    getVotes(function() {
        job.start();
    });
}

function votes(res) {
    Setting.findOne({key: 'votes-enabled'}, function(err, setting) {
        if (err || !setting || !setting.value) {
            res.json({});
            return;
        }

        res.json({
            votes: votes
        });
    });
}

function status() {
    if (votes === -1) {
        return {
            service: 'votes',
            error: 'No votes received',
            statusCode: 500
        };
    }

    return {
        service: 'votes',
        statusCode: 200
    };
}

function asJson() {
    return Setting.findOne({key: 'votes-enabled'}).then((setting) => {
        if (!setting || !setting.value) {
            return [];
        }

        if (votes === -1) {
            return [];
        }

        return {
            type: 'votes',
            votes: votes
        };
    });
};

module.exports = {
    get: get,
    votes: votes,
    status: status,
    asJson: asJson
};

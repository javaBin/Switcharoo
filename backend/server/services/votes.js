var cron = require('cron').CronJob;
var config = require('../config').votes;
var Service = require('../models').Service;
var request = require('request');
const log = require('../log');

var cronPattern = config.cronPattern || '0 */10 * * * *';

var job = new cron(cronPattern, getVotes);

var votes = -1;

function getVotes(complete) {
    request(config.url, function(error, response, body) {
        if (error)
            return log.error(error);

        try {
            body = JSON.parse(body);
        } catch (e) {
            log.error('Error trying to parse response from votes');
            log.error(e);
            return undefined;
        }

        if (!body.votes) {
            return undefined;
        }
        votes = body.votes;
        log.info('Got new votes from backend');

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
    Service.findOne({key: 'votes-enabled'}).then(function(service) {
        if (service && !service.value) {
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
    return Service.findOne({key: 'votes-enabled'}).then((service) => {
        if (service && !service.value) {
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

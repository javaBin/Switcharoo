var Program = require('./program');
var Twitter = require('./twitter');
var Votes = require('./votes');
var _ = require('lodash');

function get() {
	var services = [
		Program.status(),
		Twitter.status(),
    Votes.status()
	];

	var errors = _(services).any(function(service) { return service.statusCode !== 200; });

	return {
		statusCode: errors ? 500 : 200,
		services: services
	};
}

module.exports = {
	get: get
};

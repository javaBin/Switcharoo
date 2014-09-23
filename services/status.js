var Program = require('./program');
var Twitter = require('./twitter');
var Instagram = require('./instagram');

function get() {
	var program = Program.status();
	return {
		statusCode: 200,
		program: program
	};
}

module.exports = {
	get: get
};
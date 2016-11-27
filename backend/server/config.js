var home_folder = process.env.HOME;
var config = require(home_folder + '/.switcharoo.json');

module.exports = config;
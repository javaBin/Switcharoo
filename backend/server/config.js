const fs = require('fs');
const path = require('path');
const home_folder = process.env.HOME;
if (!fs.existsSync(path.resolve(home_folder + '/.switcharoo.json'))) {
    console.error('Can’t find settings file, exiting');
    process.exit(1);
}

const config = require(home_folder + '/.switcharoo.json');

if (!fs.existsSync(path.resolve(config.app.uploadDir))) {
    console.error('Upload directory does not exist, please create it');
    process.exit(1);
}

module.exports = config;

var restful = require('node-restful');
var mongoose = restful.mongoose;
var config = require('../config');
var basicAuth = require('../basicAuth')(config.app.user, config.app.pass);

var Setting = restful.model('settings', mongoose.Schema({
    key: 'string',
    value: 'boolean'
})).methods(['get', 'put', 'post']);
Setting.before('put', basicAuth);
Setting.before('post', basicAuth);

module.exports = Setting;
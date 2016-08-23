var restful = require('node-restful');
var mongoose = restful.mongoose;
var config = require('../config');
var basicAuth = require('../basicAuth')(config.app.user, config.app.pass);

var Slide = restful.model('slides', mongoose.Schema({
    title: 'string',
    body: 'string',
    visible: 'boolean',
    type: 'string',
    index: 'string'
}))
.methods(['get', 'put', 'post', 'delete'])
.updateOptions({'new': true});
Slide.before('put', basicAuth);
Slide.before('post', basicAuth);
Slide.before('delete', basicAuth);

module.exports = Slide;
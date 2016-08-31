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
Slide.after('get', (req, res, next) => {
    const program = res.locals.bundle;
    if (Array.isArray(program)) {
        res.locals.bundle = res.locals.bundle.sort((a, b) => parseInt(a.index) > parseInt(b.index));
    }

    next();
});

module.exports = Slide;

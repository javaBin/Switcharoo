var Twitter = require('./services/twitter');
var Instagram = require('./services/instagram');
var Program = require('./services/program');
var Slide = require('./models/slide');
var Setting = require('./models/setting');
var Status = require('./services/status');
var morgan = require('morgan');
var multer = require('multer');
var config = require('./config');
var basicAuth = require('./basicAuth')(config.app.user, config.app.pass);
var bodyParser = require('body-parser');
var path = require('path');

function configure(app, express, basePath) {
    app.set('port', config.app.port);
    app.use(bodyParser.json());
    app.use(express.static(path.join(basePath, 'public')));
    app.use(morgan(config.app.env));
    app.use(multer({dest: './public/uploads', rename: function(fieldname, filename) {
        return filename.replace(/\W+/g, '-').toLowerCase() + (new Date().getTime());
    }}));

    app.get('/status', function(req, res) {
        var status = Status.get();
        res.status(status.statusCode).json(status);
    });

    app.get('/twitter', function(req, res) {
        Twitter.tweets(res);
    });

    app.get('/instagram', function(req, res) {
        Instagram.media(res);
    });

    app.get('/program', function(req, res) {
        var all = (typeof req.query.all !== 'undefined');
        Program.program(all, res);
    });

    app.post('/image', function(req, res) {
        res.json({filepath: '/' + req.files.image.path.replace('public/','')});
    });

    Slide.register(app, '/slides');
    Setting.register(app, '/settings');

    app.use(basicAuth);
    app.use('/admin', express.static(path.join(basePath, 'admin')));
}

module.exports = {
    configure: configure
};
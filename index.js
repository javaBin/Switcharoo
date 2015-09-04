var express = require('express');
var bodyParser = require('body-parser');
var config = require('./config');
var basicAuth = require('./basicAuth')(config.app.user, config.app.pass);
var Program = require('./services/program')
var Twitter = require('./services/twitter');
var Instagram = require('./services/instagram');
var Status = require('./services/status');
var morgan = require('morgan');
var restful = require('node-restful');
var mongoose = restful.mongoose;
var multer = require('multer');
var _ = require('lodash');
var Slide = require('./models/slide');
var Setting = require('./models/setting');

mongoose.connect(config.mongodb.connection_string);

Program.get();
Twitter.get();
Instagram.get();

var app = express();
app.set('port', config.app.port);
app.use(bodyParser.json());
app.use(express.static(__dirname + '/public'));
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
app.use('/admin', express.static(__dirname + '/admin'));

app.listen(app.get('port'), function() {
	console.log('Server listening on http://localhost:' + app.get('port'));
});

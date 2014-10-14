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

mongoose.connect(config.mongodb.connection_string);

Program.get();
//Twitter.get();
//Instagram.get();

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
	res.json(Twitter.tweets());
});

app.get('/instagram', function(req, res) {
	res.json(Instagram.media());
});

app.get('/program', function(req, res) {
	var all = (typeof req.query.all !== 'undefined');
	res.json(Program.program(all));
});

app.post('/image', function(req, res) {
	res.json({filepath: '/' + req.files.image.path.replace('public/','')});
});

var Slide = restful.model('slides', mongoose.Schema({
	title: 'string',
	body: 'string',
	visible: 'boolean',
	type: 'string',
	index: 'string'
})).methods(['get', 'put', 'post', 'delete']);
Slide.before('put', basicAuth);
Slide.before('post', basicAuth);
Slide.before('delete', basicAuth);
Slide.register(app, '/slides');

app.use(basicAuth);
app.use('/admin', express.static(__dirname + '/admin'));

app.listen(app.get('port'), function() {
	console.log('Server listening on http://localhost:' + app.get('port'));
});
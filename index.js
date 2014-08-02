var express = require('express');
var bodyParser = require('body-parser');
var home_folder = process.env.HOME;
var config = require(home_folder + '/.switcharoo');
var basicAuth = require('./basicAuth')(config.app.user, config.app.pass);
var Program = require('./program')
var twit = require('twit');
var morgan = require('morgan');
var restful = require('node-restful');
var mongoose = restful.mongoose;
var Twitter = new twit(config.twitter);
var Instagram = require('instagram-node-lib');
var multer = require('multer');
Instagram.set('client_id', config.instagram.client_id);
Instagram.set('client_secret', config.instagram.client_secret);

mongoose.connect(config.mongodb.connection_string);

Program.get();

var app = express();
app.set('port', config.app.port);
app.use(bodyParser.json());
app.use(express.static(__dirname + '/public'));
app.use(morgan(config.app.env));
app.use(multer({dest: './public/uploads', rename: function(fieldname, filename) {
	return filename.replace(/\W+/g, '-').toLowerCase() + (new Date().getTime());
}}));

app.get('/twitter', function(req, res) {
	Twitter.get('search/tweets', {q: '#JavaZone', count: 10}, function(err, data, response) {
		if (err)
			return res.json(500, { err: err.message });

		res.json(data);
	});
});

app.get('/instagram', function(req, res) {
	Instagram.tags.recent({name: 'javazone', complete: function(data) {
		res.json(data);
	}});
});

app.get('/program', function(req, res) {
	res.json(Program.program());
});

app.post('/image', function(req, res) {
	res.json({filepath: req.files.image.path.replace('public/','')});
});

var Slide = restful.model('slides', mongoose.Schema({
	title: 'string',
	body: 'string',
	background: 'string',
	visible: 'boolean',
	type: 'string'
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
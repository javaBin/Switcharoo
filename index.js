var express = require('express');
var config = require('./configuration');
var bodyParser = require('body-parser');
var basicAuth = require('./basicAuth')(config.app.user, config.app.pass);
var twit = require('twit');
var morgan = require('morgan');
var restful = require('node-restful');
var mongoose = restful.mongoose;
var Twitter = new twit(config.twitter);
var Instagram = require('instagram-node-lib');
Instagram.set('client_id', config.instagram.client_id);
Instagram.set('client_secret', config.instagram.client_secret);

mongoose.connect(config.mongodb.connection_string);

var app = express();
app.use(bodyParser.json());
app.use(express.static(__dirname + '/public'));
app.use(morgan('dev'));

/*app.get('/slides', function(req, res) {
	var slides = [
		{
			view: 'info',
			id: 'info'
		}, {
			view: 'twitter'
		}, {
			view: 'instagram'
		}
	];
	res.json({'slides': slides});
});*/

/*app.get('/slides/:id', function(req, res) {
	console.log("Getting slide " + req.params.id);
	res.json({'header': req.params.id});
});*/

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
	}})
});

function authorize_slides(req, res, next) {
	if (req.query.pwd !== config.app.pwd)
		return rs.json(401, {message: 'Wrong password'});

	next();
}

var Slide = restful.model('slides', mongoose.Schema({
	title: 'string',
	body: 'string',
	background: 'string',
	visible: 'boolean'
})).methods(['get', 'put', 'post', 'delete']);
Slide.before('put', basicAuth);
Slide.before('post', basicAuth);
Slide.before('delete', basicAuth);
Slide.register(app, '/slides');

app.use(basicAuth);
app.use('/admin', express.static(__dirname + '/admin'));

app.listen(config.app.port, function() {
	console.log('Server listening on http://localhost:' + config.app.port);
});
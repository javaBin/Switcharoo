var express = require('express');
var bodyParser = require('body-parser');
//var config = require(home_folder + '/.switcharoo');
var basicAuth = require('./basicAuth')(process.env.BASIC_USER, process.env.BASIC_PASS);
var Program = require('./program')
var twit = require('twit');
var morgan = require('morgan');
var restful = require('node-restful');
var mongoose = restful.mongoose;
var twitter_config = {
	consumer_key: process.env.TWITTER_CONSUMER_KEY,
	consumer_secret: process.env.TWITTER_CONSUMER_SECRET,
	access_token: process.env.TWITTER_ACCESS_TOKEN,
	access_token_secret: process.env.TWITTER_ACCESS_TOKEN_SECRET
}
var Twitter = new twit(twitter_config);
var Instagram = require('instagram-node-lib');
Instagram.set('client_id', process.env.INSTAGRAM_CLIENT_ID);
Instagram.set('client_secret', process.env.INSTAGRAM_CLIENT_SECRET);

var mongo_vars = {
	db: process.env.MONGODB_DATABASE,
	host: process.env.MONGODB_HOST,
	port: process.env.MONGODB_POST,
	username: process.env.MONGODB_USERNAME,
	password: process.env.MONGODB_PASSWORD,
	url: process.env.MONGO_URL
};

console.log("=================");
console.log(mongo_vars.url);

mongoose.connect(mongo_vars.url);

Program.get();

var app = express();
app.set('port', process.env.PORT);
app.use(bodyParser.json());
app.use(express.static(__dirname + '/public'));
//app.use(morgan(config.app.env));

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
})

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

app.listen(app.get('port'), function() {
	console.log('Server listening on http://localhost:' + app.get('port'));
});
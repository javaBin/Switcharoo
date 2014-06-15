var express = require('express');
var fs = require('fs');
var twit = require('twit');
var config = require('./configuration');

var Twitter = new twit(config.twitter);
var Instagram = require('instagram-node-lib');
Instagram.set('client_id', config.instagram.client_id);
Instagram.set('client_secret', config.instagram.client_secret);

var app = express();
app.use(express.static(__dirname + '/public'));

app.get('/slides', function(req, res) {
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
});

app.get('/slides/:id', function(req, res) {
	console.log("Getting slide " + req.params.id);
	res.json({'header': req.params.id});
});

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

app.listen(1337);
console.log("Now listening on http://localhost:1337");
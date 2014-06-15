var express = require('express');
var fs = require('fs');
var twit = require('twit');
var config = require('./configuration');

var app = express();
var Twitter = new twit(config.twitter);

app.use(express.static(__dirname + '/public'));

app.get('/slides', function(req, res) {
	var slides = [
		{
			view: 'info',
			id: 'info'
		}, {
			view: 'twitter',
			id: 'twitter'
		}, {
			view: 'instagram',
			id: 'instagram'
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
	res.json({'header': 'Instagram'});
});

app.listen(1337);
console.log("Now listening on http://localhost:1337");
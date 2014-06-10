var express = require('express');
var fs = require('fs');

var app = express();

app.use(express.static(__dirname + '/public'));

app.get('/slides', function(req, res) {
	var slides = ['info', 'twitter', 'instagram'];
	res.json({'slides': slides});
});

app.get('/twitter', function(req, res) {
	res.json({'header': 'Twitter'})
});

app.get('/instagram', function(req, res) {
	res.json({'header': 'Instagram'});
});

app.listen(1337);
console.log("Now listening on http://localhost:1337");
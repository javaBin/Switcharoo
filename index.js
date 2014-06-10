var express = require('express');
var fs = require('fs');

var app = express();

app.use(express.static(__dirname + '/public'));

app.get('/twitter', function(req, res) {
	res.end("lol");
});

app.listen(1337);
console.log("Now listening on http://localhost:1337");
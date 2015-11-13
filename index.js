var express = require('express');
var config = require('./server/config');
var Program = require('./server/services/program')
var Twitter = require('./server/services/twitter');
var Instagram = require('./server/services/instagram');
var mongoose = require('node-restful').mongoose;
var server = require('./server/server');
var basePath = __dirname;

mongoose.connect(config.mongodb.connection_string);

Program.get();
// Twitter.get();
// Instagram.get();

var app = express();

server.configure(app, express, basePath);

app.listen(app.get('port'), function() {
	console.log('Server listening on http://localhost:' + app.get('port'));
});

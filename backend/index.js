var express = require('express');
var config = require('./server/config');
var Program = require('./server/services/program');
var Twitter = require('./server/services/twitter');
var server = require('./server/server');
const models = require('./server/models');
var basePath = __dirname;

Program.get();
Twitter.get();

var app = express();

server.configure(app, express, basePath, models);

models.sequelize.sync().then(() => {
    app.listen(app.get('port'), function() {
	      console.log('Server listening on http://localhost:' + app.get('port'));
    });
});

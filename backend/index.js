var config = require('./server/config');
var Program = require('./server/services/program');
var Twitter = require('./server/services/twitter');
var appConfig = require('./server/server');
const models = require('./server/models');
const log = require('./server/log');
const ws = require('./server/ws');
var basePath = __dirname;
const app = require('express')();
const server = require('http').createServer(app);
const io = require('socket.io')(server);

Program.get();
Twitter.get();

appConfig.configure(app, basePath, models);
ws(io);

models.sequelize.sync().then(() => {
    log.info('Database synced');
    server.listen(app.get('port'), function() {
	      log.info('Server listening on http://localhost:' + app.get('port'));
    });
});

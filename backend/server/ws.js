const log = require('./log');
const util = require('util');

const USER = '/users';
const ADMIN = '/admin';

module.exports = function(io) {

    log.info('Setting up websocket');

    io.of(ADMIN).on('connection', (socket) => {
        log.info('Admin connected to websocket');
        socket.emit('event', 'Hello, admin');
        io.of(USER).clients((err, clients) => {
            if (err) {
                console.log(err);
                return;
            } else {
                socket.emit('event', clients.length + '');
            }
        });
    });

    io.of(USER).on('connection', (socket) => {
        log.info('Client connected to websocket');

        socket.on('disconnect', () => {
            io.of(USER).clients((err, clients) => {
                if (err) {
                    console.log(err);
                    return;
                } else {
                    io.of(ADMIN).emit('event', clients.length + '');
                }
            });
        });

        io.of(USER).clients((err, clients) => {
            if (err) {
                console.log(err);
                return;
            } else {
                io.of(ADMIN).emit('event', clients.length + '');
            }
        });
    });

};

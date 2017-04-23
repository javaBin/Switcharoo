var Twitter = require('./services/twitter');
var Program = require('./services/program');
var Status = require('./services/status');
var Votes = require('./services/votes');
var CssGenerator = require('./services/css-generator');
var morgan = require('morgan');
var multer = require('multer');
var config = require('./config');
var bodyParser = require('body-parser');
var jwt = require('express-jwt');
var path = require('path');
const express = require('express');

var security = jwt({
    secret: config.security.secret,
    audience: config.security.audience
});

function configure(app, basePath, models) {
    app.set('port', config.app.port);
    app.use(bodyParser.json());
    app.use(express.static(path.join(basePath, '..', 'dist', 'public')));
    app.use('/uploads', express.static(path.resolve(config.app.uploadDir)));
    app.use(morgan('combined'));

    var storage = multer.diskStorage({
        destination: function(req, file, cb) {
            cb(null, path.resolve(config.app.uploadDir));
        },
        filename: function(req, file, cb) {
            var f = file.originalname.split('.');
            cb(null, Date.now() + '.' + f[f.length - 1]);
        }
    });

    var upload = multer({storage: storage});

    app.get('/status', function(req, res) {
        var status = Status.get();
        res.status(status.statusCode).json(status);
    });

    app.get('/twitter', function(req, res) {
        Twitter.tweets(res);
    });

    app.get('/instagram', function(req, res) {
        Instagram.media(res);
    });

    app.get('/program', function(req, res) {
        var all = (typeof req.query.all !== 'undefined');
        Program.program(all, res);
    });

    app.get('/custom.css', function(req, res) {
        CssGenerator.css(res);
    });

    require('./routes/slides')(app, security);
    require('./routes/services')(app, security);
    require('./routes/css')(app, security);
    require('./routes/settings')(app, security);

    app.get('/votes', function(req, res) {
        Votes.votes(res);
    });

    app.get('/data', (req, res) => {
        res.header('Access-Control-Allow-Origin', '*');
        res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
        Promise.all([
            models.Slide.findAll({where: {visible: true}, order: 'index'}),
            Twitter.asJson(),
            Program.asJson()
            /* Votes.asJson()*/
        ]).then((r) => {
            const slides = r[0].map(slide => slide.get({plain: true}));
            res.json({slides: slides.concat(r[1]).concat(r[2])});
            /* res.json({slides: program.concat(r[1]).concat(r[2]).concat(r[3])});*/
        }).catch(() => {
            res.status(500).send();
        });
    });

    function getType(mimetype) {
        if (mimetype.indexOf('image') >= 0) {
            return 'image';
        }

        if (mimetype.indexOf('video') >= 0) {
            return 'video';
        }

        return 'text';
    }

    app.post('/image', upload.single('image'), function(req, res) {
        var filename = req.file.filename;
        var type = getType(req.file.mimetype);
        res.json({location: '/uploads/' + filename, filetype: type});
    });

    app.use('/admin', express.static(path.join(basePath, '..', 'dist', 'admin')));
}

module.exports = {
    configure: configure
};

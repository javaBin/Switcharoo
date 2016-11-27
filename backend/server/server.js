var Twitter = require('./services/twitter');
var Program = require('./services/program');
var Status = require('./services/status');
var Votes = require('./services/votes');
var morgan = require('morgan');
var multer = require('multer');
var config = require('./config');
var basicAuth = require('./basicAuth')(config.app.user, config.app.pass);
var bodyParser = require('body-parser');
var path = require('path');
var ffmpeg = require('fluent-ffmpeg');

function configure(app, express, basePath) {
    app.set('port', config.app.port);
    app.use(bodyParser.json());
    app.use(express.static(path.join(basePath, 'dist', 'public2')));
    app.use(morgan('combined'));

    var storage = multer.diskStorage({
        destination: function(req, file, cb) {
            cb(null, path.resolve(basePath, 'dist', 'public2', 'uploads'));
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

    require('./routes/slides')(app);
    require('./routes/settings')(app);

    app.get('/votes', function(req, res) {
        Votes.votes(res);
    });

    app.get('/data', (req, res) => {
        res.header('Access-Control-Allow-Origin', '*');
        res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
        Promise.all([
            Slide.find({visible: true}),
            Twitter.asJson(),
            Program.asJson(),
            Votes.asJson()
        ]).then((r) => {
            const program = r[0].sort((a, b) => parseInt(a.index) > parseInt(b.index));
            res.json({slides: program.concat(r[1]).concat(r[2]).concat(r[3])});
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
        console.log(req.file);
        var filename = req.file.filename;
        var type = getType(req.file.mimetype);
        if (type === 'image') {
            res.json({location: '/uploads/' + filename, filetype: type});
        } else {
            ffmpeg(path.resolve(basePath, 'dist', 'public2', 'uploads', filename))
                .on('end', function() {
                    res.json({location: '/uploads/' + filename, filetype: type, thumbnail: '/uploads/' + filename + '.png'});
                }).screenshots({
                    timestamps: ['50%'],
                    filename: '%f.png',
                    folder: path.resolve(basePath, 'dist', 'public2', 'uploads'),
                    size: '368x230'
                });
        }
    });

    app.use(basicAuth);
    app.use('/admin', express.static(path.join(basePath, 'dist', 'admin2')));
    app.use('/adminold', express.static(path.join(basePath, 'dist', 'admin')));
}

module.exports = {
    configure: configure
};

const Slide = require('../models').Slide;

module.exports = function(app, security) {

    app.get('/slides', security, (req, res) => {
        Slide.findAll({order: 'index'}).then(slides => res.json(slides));
    });

    app.get('/slides/:id', security, (req, res) => {
        Slide.findById(req.params.id).then(slide => {
            if (!slide) {
                res.status(404).send();
                return;
            }

            res.json(slide.toJSON());
        });
    });

    app.post('/slides', security, (req, res) => {
        Slide.create({
            title: req.body.title,
            body: req.body.body,
            visible: req.body.visible,
            type: req.body.type,
            index: req.body.index,
            name: req.body.name
        }).then((instance) => {
            if (!instance) {
                res.status(500).send();
                return;
            }
            res.json(instance.toJSON());
        }).catch(() => {
            res.status(500).send();
        });
    });

    app.put('/slides/:id', security, (req, res) => {
        Slide.findById(req.params.id).then(slide => {
            if (!slide) {
                res.status(404).send();
                return;
            }

            slide.update({
                title: req.body.title,
                body: req.body.body,
                visible: req.body.visible,
                index: req.body.index,
                name: req.body.name
            }).then(newSlide => {
                res.json(newSlide.toJSON());
            });
        }).catch(() => {
            res.status(500).send();
        });
    });

    app.delete('/slides/:id', security, (req, res) => {
        Slide.findById(req.params.id).then(slide => {
            if (!slide) {
                res.status(404).send();
                return;
            }
            slide.destroy().then(() => {
                res.status(200).send();
            }).catch(() => {
                res.status(500).send();
            });
        }).catch(() => {
            res.status(500).send();
        });
    });
};

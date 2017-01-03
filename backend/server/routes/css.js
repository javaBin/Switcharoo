const Css = require('../models').Css;

module.exports = function(app, security) {
    app.get('/css', security, (req, res) => {
        Css.findAll().then(css => res.json(css));
    });

    app.get('/css/:id', security, (req, res) => {
        Css.findById(req.params.id).then(css => {
            if (!css) {
                res.status(404).send();
                return;
            }

            res.json(css.toJSON());
        });
    });

    app.post('/css', security, (req, res) => {
        Css.create({
            selector: req.body.selector,
            property: req.body.property,
            value: req.body.value,
            type: req.body.type,
            title: req.body.title
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

    app.put('/css/:id', security, (req, res) => {
        Css.findById(req.params.id).then(css => {
            if (!css) {
                res.status(404).send();
                return;
            }

            css.update({
                selector: req.body.selector,
                property: req.body.property,
                value: req.body.value,
                type: req.body.type
            }).then(newCss => {
                res.json(newCss.toJSON());
            });
        }).catch(() => {
            res.status(500).send();
        });
    });

    app.delete('/css/:id', security, (req, res) => {
        Css.findById(req.params.id).then(css => {
            if (!css) {
                res.status(404).send();
                return;
            }

            css.destroy.then(() => {
                res.status(200).send();
            }).catch(() => {
                res.status(500).send();
            });
        }).catch(() => {
            res.status(500).send();
        });
    });
};

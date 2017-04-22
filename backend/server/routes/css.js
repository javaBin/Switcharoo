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

    app.put('/css', security, (req, res) => {
        const styles = req.body.map(stylesJson => {
            return Css.findById(stylesJson.id).then(style => {
                if (!style) {
                    return Promise.resolve(stylesJson);
                } else {
                    return style.update({
                        selector: stylesJson.selector,
                        property: stylesJson.property,
                        value: stylesJson.value,
                        type: stylesJson.type
                    }).then (newStyle => {
                        return newStyle.toJSON();
                    });
                }
            });
        });

        Promise.all(styles).then(updatedStyles => {
            res.json(updatedStyles);
        }).catch(reason => {
            res.status(500).body(reason).send();
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

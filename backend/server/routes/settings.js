const Setting = require('../models').Setting;

module.exports = function(app) {
    app.get('/settings', (req, res) => {
        Setting.findAll().then(settings => res.json(settings));
    });

    app.post('/settings', (req, res) => {
        Setting.create({
            key: req.body.key,
            value: req.body.value
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

    app.put('/settings/:id', (req, res) => {
        Setting.findById(req.params.id).then(setting => {
            if (!setting) {
                res.status(404).send();
                return;
            }

            setting.update({
                key: req.body.key,
                value: req.body.value
            }).then(newSetting => {
                res.json(newSetting.toJSON());
            });
        }).catch(() => {
            res.status(500).send();
        });
    });
};

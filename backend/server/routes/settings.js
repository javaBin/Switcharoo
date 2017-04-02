const Setting = require('../models').Setting;

module.exports = function(app, security) {
    app.get('/settings', security, (req, res) => {
        Setting.findAll({order: 'id'}).then(settings => res.json(settings));
    });

    app.post('/settings', security, (req, res) => {
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

    app.put('/settings/:id', security, (req, res) => {
        Setting.findById(req.params.id).then(setting => {
            if (!setting) {
                res.status(404).send();
                return;
            }

            setting.update({
                value: !setting.get('value')
            }).then(newSetting => {
                res.json(newSetting.toJSON());
            });
        }).catch(() => {
            res.status(500).send();
        });
    });
};

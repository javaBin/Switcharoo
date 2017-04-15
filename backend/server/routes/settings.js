const Setting = require('../models').Setting;

module.exports = function(app, security) {
    app.get('/settings', security, (req, res) => {
        Setting.findAll({order: 'id'}).then(settings => res.json(settings));
    });

    app.post('/settings', security, (req, res) => {
        Setting.create({
            key: req.body.key,
            hint: req.body.hint,
            value: req.body.value
        }).then(instance => {
            if (!instance) {
                res.status(500).send();
            } else {
                res.json(instance.toJSON());
            }
        }).catch(() => {
            res.status(500).send();
        });
    });

    app.put('/settings', security, (req, res) => {
        const settings = req.body.map(settingJson => {
            return Setting.findById(settingJson.id).then(setting => {
                if (!setting) {
                    return Promise.resolve(settingJson);
                } else {
                    return setting.update({
                        key: settingJson.key,
                        hint: settingJson.hint,
                        value: settingJson.value
                    }).then(newSetting => {
                        return newSetting.toJSON();
                    });
                }
            });
        });

        Promise.all(settings).then(updatedSettings => {
            res.json(updatedSettings);
        }).catch(reason => {
            res.status(500).body(reason).send();
        });
    });

    app.put('/settings/:id', security, (req, res) => {
        Setting.findById(req.params.id).then(setting => {
            if (!setting) {
                res.status(404).send();
            } else {
                setting.update({
                    key: req.body.key,
                    hint: req.body.hint,
                    value: req.body.value
                }).then(newSetting => {
                    res.json(newSetting.toJSON());
                });
            }
        }).catch(() => {
            res.status(500).send();
        });
    });
};

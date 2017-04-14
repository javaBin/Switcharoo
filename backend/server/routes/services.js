const Service = require('../models').Service;

module.exports = function(app, security) {
    app.get('/services', security, (req, res) => {
        Service.findAll({order: 'id'}).then(services => res.json(services));
    });

    app.post('/services', security, (req, res) => {
        Service.create({
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

    app.put('/services/:id', security, (req, res) => {
        Service.findById(req.params.id).then(service => {
            if (!service) {
                res.status(404).send();
                return;
            }

            service.update({
                value: !service.get('value')
            }).then(newService => {
                res.json(newService.toJSON());
            });
        }).catch(() => {
            res.status(500).send();
        });
    });
};

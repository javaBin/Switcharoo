(function(Admin, Backbone, Handlebars) {

    var view = Backbone.View.extend({

        tagName: 'div',

        events: {
            'click .enabled': 'toggleEnabed'
        },

        initialize: function(options) {
            this.template = Handlebars.compile($(options.template).html());
            if (this.model)
                this.model.on('change', this.render, this);
        },

        render: function() {
            var model = this.model.toJSON()
            console.log(model);
            this.$el.html(this.template(model));
            return this.el;
        },

        toggleEnabed: function(event) {
            this.model.set({'value': !this.model.get('value')});
            console.log(this.model.get('value'));
            this.model.save();
        }
    });

    var model = Backbone.Model.extend({

        urlRoot: '/settings',

        idAttribute: '_id',

        defaults: {
            'key': '',
            'value': false
        }

    });

    Admin.Setting = {
        view: view,
        model: model
    };

})(window.Admin = window.Admin || {}, window.Backbone, window.Handlebars);
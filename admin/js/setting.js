import Backbone from 'backbone';
import template from './setting.hbs';

var view = Backbone.View.extend({

    tagName: 'div',

    events: {
        'click .enabled': 'toggleEnabed'
    },

    initialize: function(options) {
        this.template = template;
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

var Setting = {
    view: view,
    model: model
};

export default Setting;

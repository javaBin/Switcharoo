import Backbone from 'backbone';
import template from './settings.hbs';
import Setting from './setting';

var view = Backbone.View.extend({

    initialize: function(options) {
        this.template = template;
        this.collection.on('sync', this.render, this);
        this.collection.fetch();
        Backbone.Events.on('settings:reload', this.collection.fetch, this);
    },

    render: function() {
        var self = this;
        var container = document.createDocumentFragment();
        this.$el.html(this.template());
        this.settings = [];
        this.collection.each(function(model) {
            var view = new Setting.view({model: model});
            self.settings.push(view);
            container.appendChild(view.render());
        });
        this.$el.find('ul').append(container);
        return this.el;
    },

    assign: function(view, selector) {
        view.setElement(this.$(selector)).render();
    }
});

var collection = Backbone.Collection.extend({
    model: Setting.model,
    url: '/settings'
});

var Settings = {
    view: view,
    collection: collection
};

export default Settings;

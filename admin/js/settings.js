(function(Admin, Backbone, Handlebars) {

    var view = Backbone.View.extend({

        initialize: function(options) {
            this.template = Handlebars.compile($(options.template).html());
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
                var view = new Admin.Setting.view({model: model, template: '#setting-template'});
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
        model: Admin.Setting.model,
        url: '/settings'
    });

    Admin.Settings = {
        view: view,
        collection: collection
    };

})(window.Admin = window.Admin || {}, window.Backbone, window.Handlebars);
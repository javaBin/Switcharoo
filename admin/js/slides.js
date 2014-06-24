(function(Admin, Backbone, Handlebars) {

	var view = Backbone.View.extend({

		initialize: function(options) {
			this.template = Handlebars.compile($(options.template).html());
			this.collection.on('sync remove', this.render, this);
			this.collection.fetch();
			Backbone.Events.on('slides:reload', this.collection.fetch, this);
		},

		render: function() {
			var self = this;
			var container = document.createDocumentFragment();
			this.$el.html(this.template());
			this.slides = [];
			this.collection.each(function(model) {
				var view = new Admin.Slide.view({model: model, template: '#slide-template'});
				self.slides.push(view);
				container.appendChild(view.render());
			});
			this.$el.find('ol').append(container);
			return this.el;
		},

		assign: function(view, selector) {
			view.setElement(this.$(selector)).render();
		}
	});

	var collection = Backbone.Collection.extend({
		model: Admin.Slide.model,
		url: '/slides'
	});

	Admin.Slides = {
		view: view,
		collection: collection
	};

})(window.Admin = window.Admin || {}, window.Backbone, window.Handlebars);
(function(Admin, Backbone, Handlebars) {

	var view = Backbone.View.extend({

		initialize: function(options) {
			this.template = Handlebars.compile($(options.template).html());
			this.model.on('change', this.render, this);
			this.model.fetch();
		},

		render: function() {
			var model = this.model.toJSON();
			console.log(model);
			this.$el.html(this.template(model));
			return this.el;
		},

		assign: function(view, selector) {
			view.setElement(this.$(selector)).render();
		}
	});

	var model = Backbone.Model.extend({
		url: '/slides'
	});

	Admin.Slides = {
		view: view,
		model: model
	};

})(window.Admin = window.Admin || {}, window.Backbone, window.Handlebars);
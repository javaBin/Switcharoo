(function(Admin, Backbone, Handlebars) {

	var view = Backbone.View.extend({

		initialize: function(options) {
			this.template = Handlebars.compile($(options.template).html());
			this.slides = new Admin.Slides.view({model: new Admin.Slides.model(), template: '#slides-template'});
		},

		render: function() {
			this.$el.html(this.template());
			this.assign(this.slides, '.slides');
			return this.el;
		},

		assign: function(view, selector) {
			view.setElement(this.$(selector)).render();
		}
	});

	Admin.App = {
		view: view
	};

})(window.Admin = window.Admin || {}, window.Backbone, window.Handlebars);
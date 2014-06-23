(function(Admin, Backbone, Handlebars) {

	var view = Backbone.View.extend({

		initialize: function(options) {
			this.template = $(options.template).html();
			this.model.on('change', this.render, this);
		}
	});

	var model = Backbone.Model.extend({
		urlRoot: '/slides'
	});

	Admin.Slide = {
		view: view,
		model: model
	};

})(window.Admin = window.Admin || {}, window.Backbone, window.Handlebars);
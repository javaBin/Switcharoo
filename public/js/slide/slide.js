(function(Switcharoo, Backbone) {
	"use strict";

	var Slide = Backbone.View.extend({

		initialize: function(options) {
			//this.model.on('change', this.render, this);
			this.template = Handlebars.compile($(options.template).html());
		},

		render: function() {
			var model = this.model.toJSON();
			this.$el.html(this.template(model));
			return this.el;
		},

		html: function() {
			return this.$el.html();
		}
		
	});

	Switcharoo.Slide = Slide;

})(window.Switcharoo = window.Switcharoo || {}, window.Backbone, window.Handlebars);
(function(Switcharoo, Backbone) {
	"use strict";

	var Slide = Backbone.View.extend({

		initialize: function(options) {
			this.template = Handlebars.compile($(this.template).html());
		},

		render: function() {
			var model = this.model.toJSON();
			this.$el.html(this.template(model));
			return this.el;
		},

		html: function() {
			return this.el;
		}
		
	});

	Switcharoo.Slide = Slide;

})(window.Switcharoo = window.Switcharoo || {}, window.Backbone, window.Handlebars);
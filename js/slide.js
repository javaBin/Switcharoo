(function(Switcharoo, Backbone) {
	"use strict";

	var Slide = Backbone.View.extend({

		render: function() {
			var template = $(this.template).html();
			this.$el.html(Handlebars.compile(template)());
		},

		html: function() {
			return this.$el.html();
		}
		
	});

	Switcharoo.Slide = Slide;

})(window.Switcharoo = window.Switcharoo || {}, window.Backbone);
(function(Switcharoo, Backbone) {
	"use strict";

	var Slide = Backbone.View.extend({

		initialize: function() {
			this.model.on('change', this.render, this);
		},

		render: function() {
			var model = this.model.toJSON();
			var template = $(this.template).html();
			this.$el.html(Handlebars.compile(template)(model));
			this.trigger('render:done');
			return this;
		},

		html: function() {
			return this.$el.html();
		}
		
	});

	Switcharoo.Slide = Slide;

})(window.Switcharoo = window.Switcharoo || {}, window.Backbone);
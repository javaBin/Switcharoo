(function(Switcharoo, Backbone) {
	"use strict";

	var Slide = Backbone.View.extend({

		initialize: function() {
			this.model.on('change', this.render, this);
			console.log(this.model.get('id'));
		},

		render: function() {
			var model = this.model.toJSON();
			console.log(model);
			var template = $(this.template).html();
			this.$el.html(Handlebars.compile(template)(model));

			return this;
		},

		html: function() {
			return this.$el.html();
		}
		
	});

	Switcharoo.Slide = Slide;

})(window.Switcharoo = window.Switcharoo || {}, window.Backbone);
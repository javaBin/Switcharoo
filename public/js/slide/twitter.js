(function(Switcharoo, Backbone) {
	"use strict";

	var view = Switcharoo.Slide.extend({
		template: '#twitter',

		className: 'twitter',

		initialize: function() {
			this.template = Handlebars.compile($(this.template).html());
			this.model.on('change', this.render, this);
		},

		animatableElements: function() {
			return this.$el.find('h1, li');
		},

		animateIn: function() {
			return this.animatableElements();
		},

		animateOut: function() {
			return this.animatableElements();
		}
	});

	var model = Backbone.Model.extend({
		urlRoot: '/twitter'
	});

	Switcharoo.Twitter = {
		view: view,
		model: model
	};

})(window.Switcharoo = window.Switcharoo || {}, window.Backbone);
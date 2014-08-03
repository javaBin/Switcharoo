(function(Switcharoo, Backbone) {
	"use strict";

	var view = Switcharoo.Slide.extend({

		className: 'info',

		animatableElements: function() {
			return this.$el.find('h1, .body, .image');
		},

		animateIn: function() {
			return this.animatableElements();
		},

		animateOut: function() {
			return this.animatableElements();
		}
	});

	var model = Backbone.Model.extend({
		urlRoot: '/slides'
	});

	Switcharoo.Info = {
		view: view,
		model: model
	};

})(window.Switcharoo = window.Switcharoo || {}, window.Backbone);
(function(Switcharoo, Backbone) {
	"use strict";

	var view = Switcharoo.Slide.extend({

		className: 'info',

		animatableElements: function() {
			return this.$el.find('h1, .body, .image');
			//console.log(this.el);
			//return $('h1, .body');
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
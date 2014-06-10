(function(Switcharoo, Backbone) {
	"use strict";

	var view = Switcharoo.Slide.extend({
		template: '#twitter',
		className: 'twitter'
	});

	var model = Backbone.Model.extend({
		urlRoot: '/slides'
	});

	Switcharoo.Twitter = {
		view: view,
		model: model
	};

})(window.Switcharoo = window.Switcharoo || {}, window.Backbone);
(function(Switcharoo, Backbone) {
	"use strict";

	var view = Switcharoo.Slide.extend({
		template: '#instagram',
		className: 'instagram'
	});

	var model = Backbone.Model.extend({
		urlRoot: '/slides'
	});

	Switcharoo.Instagram = {
		view: view,
		model: model
	};

})(window.Switcharoo = window.Switcharoo || {}, window.Backbone);
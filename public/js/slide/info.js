(function(Switcharoo, Backbone) {
	"use strict";

	var view = Switcharoo.Slide.extend({
		template: '#info',
		className: 'info'
	});

	var model = Backbone.Model.extend({
		urlRoot: '/slides'
	});

	Switcharoo.Info = {
		view: view,
		model: model
	};

})(window.Switcharoo = window.Switcharoo || {}, window.Backbone);
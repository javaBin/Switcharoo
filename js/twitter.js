(function(Switcharoo, Backbone) {
	"use strict";

	var Twitter = Switcharoo.Slide.extend({
		template: '#twitter'
	});

	Switcharoo.Twitter = Twitter;

})(window.Switcharoo = window.Switcharoo || {}, window.Backbone);
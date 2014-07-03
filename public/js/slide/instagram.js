(function(Switcharoo, Backbone) {
	"use strict";

	var view = Switcharoo.Slide.extend({
		template: '#instagram',

		className: 'instagram',

		initialize: function() {
			this.template = Handlebars.compile($(this.template).html());
			this.model.on('change', this.render, this);
		},

		animatableElements: function() {
			return this.$el.find('img');
		}
	});

	var model = Backbone.Model.extend({
		urlRoot: '/instagram'
	});

	Switcharoo.Instagram = {
		view: view,
		model: model
	};

})(window.Switcharoo = window.Switcharoo || {}, window.Backbone);
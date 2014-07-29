(function(Switcharoo, Backbone) {
	"use strict";

	var view = Switcharoo.Slide.extend({
		template: '#program',

		className: 'program',

		initialize: function() {
			this.template = Handlebars.compile($(this.template).html());
			this.model.on('change', this.render, this);
		},

		animatableElements: function() {
			return this.$el.find('h1, ul');
		}
	});

	var model = Backbone.Model.extend({
		urlRoot: '/program'
	});

	Switcharoo.Program = {
		view: view,
		model: model
	};

})(window.Switcharoo = window.Switcharoo || {}, window.Backbone);
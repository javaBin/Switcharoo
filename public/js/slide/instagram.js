(function(Switcharoo, Backbone) {
	"use strict";

	var view = Switcharoo.Slide.extend({
		template: '#instagram',

		className: 'instagram',

		initialize: function() {
			this.template = Handlebars.compile($(this.template).html());
			this.model.on('sync', this.render, this);
			this.on('visible', this.visible, this);
		},

		animateIn: function() {
			return this.$el.find('.first');

		},

		animateOut: function() {
			return this.$el.find('.second');
		},

		visible: function() {
			var self = this;
			setTimeout(function () { self.swapImages()}, window.slideDuration / 2);
		},

		swapImages: function() {
			this.$el.find('.first').velocity('transition.flipXOut');
			this.$el.find('.second').velocity('transition.flipXIn');
		},

		shouldShow: function() {
			return this.model.has(0);
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
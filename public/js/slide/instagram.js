import Backbone from 'backbone';
import template from './instagram.hbs';
import $ from 'jquery';
import Velocity from 'velocity-animate';
import _ from 'velocity-animate/velocity.ui';
import Slide from './slide';

var view = Slide.extend({
	template: '#instagram',

	className: 'instagram',

	initialize: function() {
		this.template = template;//Handlebars.compile($(this.template).html());
		this.model.on('sync', this.render, this);
		this.on('visible', this.visible, this);
	},

	animateIn: function() {
		return this.$el.find('.first, h1');

	},

	animateOut: function() {
		return this.$el.find('.second, h1');
	},

	visible: function() {
		var self = this;
		setTimeout(function () { self.swapImages()}, window.slideDuration / 2);
	},

	swapImages: function() {
		Velocity(this.$el.find('.first').get(), 'transition.flipXOut');
		Velocity(this.$el.find('.second').get(), 'transition.flipXIn');
	},

	shouldShow: function() {
		return this.model.has('media') && this.model.get('media').length > 0;
	}
});

var model = Backbone.Model.extend({
	urlRoot: '/instagram'
});

var Instagram = {
	view: view,
	model: model
};

export default Instagram;

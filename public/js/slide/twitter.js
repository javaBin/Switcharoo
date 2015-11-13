import Backbone from 'backbone';
import Slide from './slide';
import template from './twitter.hbs';

var view = Slide.extend({
	template: '#twitter',

	className: 'twitter',

	initialize: function() {
		this.template = template;//Handlebars.compile($(this.template).html());
		this.model.on('sync', this.render, this);
	},

	animatableElements: function() {
		return this.$el.find('h1, li');
	},

	animateIn: function() {
		return this.animatableElements();
	},

	animateOut: function() {
		return this.animatableElements();
	},

	shouldShow: function() {
		return this.model.has('tweets') && this.model.get('tweets').length > 0;
	}
});

var model = Backbone.Model.extend({
	urlRoot: '/twitter'
});

var Twitter = {
	view: view,
	model: model
};

export default Twitter;

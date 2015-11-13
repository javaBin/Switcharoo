import Backbone from 'backbone';
import Slide from './slide';
import template from './program.hbs';

var view = Slide.extend({
	template: '#program',

	className: 'program',

	initialize: function() {
		//this.template = Handlebars.compile($(this.template).html());
        this.template = template;
		this.model.on('sync', this.render, this);
	},

	animatableElements: function() {
		return this.$el.find('h1, ul');
	},

	animateIn: function() {
		return this.animatableElements();
	},

	animateOut: function() {
		return this.animatableElements();
	},

    shouldShow: function() {
        return this.model.get('heading') !== 'off';
    }
});

var model = Backbone.Model.extend({
	urlRoot: '/program'
});

var Program = {
	view: view,
	model: model
};

export default Program;

import Backbone from 'backbone';
import Slide from './slide';

var view = Slide.extend({

	className: 'info',

	animatableElements: function() {
		return this.$el.find('h1, .body, .image');
	},

	animateIn: function() {
		return this.animatableElements();
	},

	animateOut: function() {
		return this.animatableElements();
	}
});

var model = Backbone.Model.extend({
	urlRoot: '/slides'
});

var Info = {
	view: view,
	model: model
};

export default Info;

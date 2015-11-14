import Backbone from 'backbone';
import template from './slides.hbs';
import Slide from './slide';
import slideTemplate from './slide.hbs';

var view = Backbone.View.extend({

	initialize: function(options) {
		this.template = template;
		this.collection.on('sync remove', this.render, this);
		this.collection.fetch();
		Backbone.Events.on('slides:reload', this.collection.fetch, this);
	},

	render: function() {
		var self = this;
		var container = document.createDocumentFragment();
		this.$el.html(this.template());
		this.settings = [];
		this.collection.each(function(model) {
			var view = new Slide.view({model: model, template: slideTemplate});
			self.settings.push(view);
			container.appendChild(view.render());
		});
		this.$el.find('ol').append(container);
		return this.el;
	},

	assign: function(view, selector) {
		view.setElement(this.$(selector)).render();
	}
});

var collection = Backbone.Collection.extend({
	model: Slide.model,
	comparator: 'index',
	url: '/slides'
});

var Slides = {
	view: view,
	collection: collection
};

export default Slides;

import Backbone from 'backbone';
import Slides from './slides';
import Slide from './slide';
import Settings from './settings';
import $ from 'jquery';
import less from '../css/admin.less';

import template from './app.hbs';
import slideTextTemplate from './slideText.hbs';
import slideImageTemplate from './slideImage.hbs';

var app = Backbone.View.extend({

	events: {
		'click .text-slide': 'createTextSlide',
		'click .image-slide': 'createImageSlide'
	},

	initialize: function(options) {
		this.template = template;
		this.slides = new Slides.view({collection: new Slides.collection()});
        this.settings = new Settings.view({collection: new Settings.collection()});
		Backbone.Events.on('slide:edit', this.edit, this);
		Backbone.Events.on('slide:edit:close', this.close, this);
		Backbone.Events.on('slide:remove', this.remove, this);
	},

	render: function() {
		this.$el.html(this.template());
		this.assign(this.slides, '.slides');
        this.assign(this.settings, '.settings');
		return this.el;
	},

	assign: function(view, selector) {
		var container = $('<div></div>');
		$(selector).append(view.setElement(container).render());
	},

	edit: function(slide) {
		var template = slide.get('type') === 'text'
			? slideTextTemplate
			: slideImageTemplate;
		this.slideEdit = new Slide.view({template: template});
		this.slideEdit.model = slide;
		this.assign(this.slideEdit, '.slide-edit');
	},

	close: function() {
		this.slideEdit.remove();
		this.slides.collection.fetch();
	},

	editText: function(slide) {
		this.slideEdit = new Slide.view({template: slideTextTemplate});
		this.slideEdit.model = model;
		this.assign(this.slideEdit, '.slide-edit');
	},

	editImage: function(slide) {
		this.imageSlideEdit.model = slide;
		this.assign(this.imageSlideEdit, '.slide-edit');
	},

	createTextSlide: function() {
		this.slideEdit = new Slide.view({template: slideTextTemplate});
		var model = new Slide.model();
		model.set('type', 'text');
		this.slideEdit.model = model;
		this.assign(this.slideEdit, '.slide-edit');
	},

	createImageSlide: function() {
		this.slideEdit = new Slide.view({template: slideImageTemplate});
		console.log('create image');
		var model = new Admin.Slide.model();
		model.set('type', 'image');
		this.slideEdit.model = model;
		this.assign(this.slideEdit, '.slide-edit');
	},

	remove: function(slide) {
		slide.model.destroy();
		this.slides.collection.remove(slide);
	}

});

var view = new app({el: $('.container')});
view.render();

(function(Switcharoo, Backbone) {
	"use strict";

	var view = Backbone.View.extend({

		initialize: function(options) {
			this.animationDuration = options.animationDuration || 500;
			Backbone.Events.on('slide:next', this.slideInNext, this);
			this.collection.once('sync', this.render, this);
		},

		render: function() {
			var slides = this.renderInfo();
			this.slides = slides;
			var special = this.renderSpecial();
			this.special = special;
			this.collection.on('sync', this.rerender, this);
			this.start();
		},

		rerender: function() {
			if (this.newSlides)
				delete this.newSlides;

			this.newSlides = this.renderInfo();
		},

		renderInfo: function() {
			var slides = [];
			this.collection.each(function(slide) {
				if (!slide.get('visible'))
					return;

				var template = slide.get('type') === 'image' ? '#slide-image-info' : '#slide-text-info';
				var view = new Switcharoo.Info.view({model: slide, template: template});
				slides.push(view);
				view.render();
			});

			return slides;
		},

		renderSpecial: function() {
			var special = [
				this.program(),
				this.twitter(),
				this.instagram()
			];
			return special;
		},

		program: function() {
			if (this.program)
				delete this.program;

			var model = new Switcharoo.Program.model();
			var view = new Switcharoo.Program.view({model: model, template: '#program'});
			model.fetch();
			return view;
		},

		twitter: function() {
			if (this.twitter)
				delete this.twitter;

			var model = new Switcharoo.Twitter.model();
			var view = new Switcharoo.Twitter.view({model: model, template: '#twitter'});
			model.fetch();
			return view;
		},

		instagram: function() {
			if (this.instagram)
				delete this.instagram;

			var model = new Switcharoo.Instagram.model();
			var view = new Switcharoo.Instagram.view({model: model, template: '#instagram'});
			model.fetch();
			return view;
		},

		start: function() {
			this.current = -1;
			var slide = this.getNext();
			this.$el.html(slide.html());
			slide.animateIn().velocity('transition.slideUpIn');
			slide.trigger('visible');
			Backbone.Events.trigger('render:done');
		},

		slideInNext: function() {
			var self = this;
			this.getSlide().animateOut().velocity('transition.slideUpOut', {
				complete: function() {
					if (self.nextIndex() === 0)
						self.setNext();

					var next = self.getNext();
					if (next instanceof Switcharoo.Twitter.view)
						self.collection.fetch();

					self.$el.html(next.html());
					next.animateIn().velocity('transition.slideUpIn');
					Backbone.Events.trigger('slide:next:done');
					next.trigger('visible');
				}
			});
		},

		setNext: function() {
			if (this.newSlides) {
				delete this.slides;
				this.slides = this.newSlides;
			}
			this.current = -1;
			delete this.newSlides;
		},

		getSlide: function(index) {
			if (typeof index === 'undefined')
				index = this.current;

			if (index < this.slides.length)
				return this.slides[index];
			
			return this.special[index - this.slides.length];
		},

		nextIndex: function() {
			var max = this.slides.length + this.special.length;
			return (this.current + 1) % max;
		},

		getNext: function() {
			var next = this.nextIndex();
			var nextSlide = this.getSlide(next);
			this.current = next;
			return nextSlide;
		}

	});

	var model = Backbone.Model.extend({
		url: '/slides'
	});

	var collection = Backbone.Collection.extend({
		model: model,

		url: '/slides'
	});

	Switcharoo.Container = {
		view: view,
		model: model,
		collection: collection
	};

})(window.Switcharoo = window.Switcharoo || {}, window.Backbone);
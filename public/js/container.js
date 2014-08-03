(function(Switcharoo, Backbone) {
	"use strict";

	var TEN_MINUTES = 1000 * 60 * 10;
	var TWO_MINUTES = 1000 * 60 * 2;

	var view = Backbone.View.extend({

		initialize: function(options) {
			this.animationDuration = options.animationDuration || 500;
			Backbone.Events.on('slide:next', this.slideInNext, this);
			this.collection.once('sync', this.render, this);
			this.getSlides = false;
			this.getProgram = false;
			this.getTwitter = false;
			this.getInstagram = false;
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
			if (this.programView)
				delete this.programView;

			var model = new Switcharoo.Program.model();
			var view = new Switcharoo.Program.view({model: model, template: '#program'});
			this.programView = view;
			model.fetch();
			return view;
		},

		twitter: function() {
			if (this.twitterView)
				delete this.twitterView;

			var model = new Switcharoo.Twitter.model();
			var view = new Switcharoo.Twitter.view({model: model, template: '#twitter'});
			this.twitterView = view;
			model.fetch();
			return view;
		},

		instagram: function() {
			if (this.instagramView)
				delete this.instagramView;

			var model = new Switcharoo.Instagram.model();
			var view = new Switcharoo.Instagram.view({model: model, template: '#instagram'});
			this.instagramView = view;
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
			this.startTimers();
		},

		startTimers: function() {
			var self = this;
			setInterval(function() { self.getSlides = true; }, TWO_MINUTES);
			setInterval(function() { self.getProgram = true; }, TEN_MINUTES);
			setInterval(function() { self.getTwitter = true; }, TEN_MINUTES);
			setInterval(function() { self.getInstagram = true; }, TEN_MINUTES);
		},

		slideInNext: function() {
			var self = this;
			this.getSlide().animateOut().velocity('transition.slideUpOut', {
				complete: function() {
					if (self.nextIndex() === 0)
						self.setNext();

					var next = self.getNext();
					if (next instanceof Switcharoo.Twitter.view && self.getSlides) {
						self.collection.fetch();
						self.getSlides = false;
					}

					if (self.nextIndex() === 1) {
						if (self.getProgram) {
							self.programView.model.fetch();
							self.getProgram = false;
						}

						if (self.getTwitter) {
							self.twitterView.model.fetch();
							self.getTwitter = false;
						}

						if (self.getInstagram) {
							self.instagramView.model.fetch();
							self.getInstagram = false;
						}
					}

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
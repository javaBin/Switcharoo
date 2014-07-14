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
			this.renderSpecial();
			this.collection.on('sync', this.rerender, this);
			this.start();
		},

		rerender: function() {
			if (this.newSlides)
				delete this.newSlides;

			this.newSlides = this.renderInfo();
			console.log("rerender");
		},

		renderInfo: function() {
			var slides = [];
			this.collection.each(function(slide) {
				if (!slide.get('visible'))
					return;

				var view = new Switcharoo.Info.view({model: slide});
				slides.push(view);
				view.render();
			});

			return slides;
		},

		renderSpecial: function() {
			this.twitter();
			this.instagram();
		},

		twitter: function() {
			if (this.twitter)
				delete this.twitter;

			var model = new Switcharoo.Twitter.model();
			var view = new Switcharoo.Twitter.view({model: model});
			model.fetch();
			this.twitter = view;
		},

		instagram: function() {
			if (this.instagram)
				delete this.instagram;

			var model = new Switcharoo.Instagram.model();
			var view = new Switcharoo.Instagram.view({model: model});
			model.fetch();
			this.instagram = view;
		},

		start: function() {
			this.current = -1;
			var slide = this.getNext();
			this.$el.html(slide.html());
			slide.animatableElements().velocity('transition.slideUpIn');
			Backbone.Events.trigger('render:done');
		},

		slideInNext: function() {
			var self = this;
			this.getSlide().animatableElements().velocity('transition.slideUpOut', {
				complete: function() {
					if (self.nextIndex() === 0)
						self.setNext();

					var next = self.getNext();
					if (next instanceof Switcharoo.Twitter.view)
						self.collection.fetch();

					self.$el.html(next.html());
					next.animatableElements().velocity('transition.slideUpIn');
					Backbone.Events.trigger('slide:next:done');
				}
			});
		},

		setNext: function() {
			delete this.slides;
			this.slides = this.newSlides;
			this.current = -1;
			delete this.nextSlides;
		},

		getSlide: function(index) {
			if (typeof index === 'undefined')
				index = this.current;

			if (index < this.slides.length)
				return this.slides[index];
			else if (index == this.slides.length)
				return this.twitter;
			else if (index == this.slides.length + 1)
				return this.instagram;

			return this.slides[0];
		},

		nextIndex: function() {
			var max = this.slides.length + 2;
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
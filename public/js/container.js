(function(Switcharoo, Backbone) {
	"use strict";

	var view = Backbone.View.extend({

		initialize: function(options) {
			this.animationDuration = options.animationDuration || 500;
			Backbone.Events.on('slide:next', this.slideInNext, this);
			this.collection.once('sync', this.render, this);
		},

		render: function() {
			this.renderAllSlides();
			this.collection.on('sync', this.renderAllSlides, this);
			this.start();
		},

		renderAllSlides: function() {
			var slides = [];
			this.collection.each(function(slide) {
				if (!slide.get('visible'))
					return;

				var view = new Switcharoo.Info.view({model: slide});
				slides.push(view);
				view.render();
			});
			slides.push(this.twitter());
			slides.push(this.instagram());
			this.slides = slides;
			console.log(slides);
			//this.start();
			return this.el;
		},

		twitter: function() {
			var model = new Switcharoo.Twitter.model();
			var view = new Switcharoo.Twitter.view({model: model});
			model.fetch();
			return view;
		},

		instagram: function() {
			var model = new Switcharoo.Instagram.model();
			var view = new Switcharoo.Instagram.view({model: model});
			model.fetch();
			return view;
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
			this.getCurrent().animatableElements().velocity('transition.slideUpOut', {
				complete: function() {
					var next = self.getNext();
					self.$el.html(next.html());
					next.animatableElements().velocity('transition.slideUpIn');
					self.checkForUpdates();
					Backbone.Events.trigger('slide:next:done');
				}
			});
		},

		getCurrent: function() {
			return this.slides[this.current];
		},

		getNext: function() {
			this.current = (this.current !== this.slides.length - 1)
				? this.current + 1
				: 0;
			return this.slides[this.current];
		},

		checkForUpdates: function() {
			var current = this.getCurrent();
			if (current instanceof Switcharoo.Twitter.view) {
				// We should check for updates from backend here,
				// at least when a certain time has passed
				this.collection.fetch();
			}
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
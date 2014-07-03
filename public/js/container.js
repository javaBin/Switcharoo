(function(Switcharoo, Backbone) {
	"use strict";

	function resolveType(slide) {
		switch (slide.view.toLowerCase()) {
			case 'info':
				return Switcharoo.Info;
			case 'twitter':
				return Switcharoo.Twitter;
			case 'instagram':
				return Switcharoo.Instagram;
			default:
				return undefined;
		}
	}

	var view = Backbone.View.extend({

		initialize: function(options) {
			this.template = Handlebars.compile($(options.template).html());;
			this.animationDuration = options.animationDuration || 500;
			Backbone.Events.on('slide:next', this.slideInNext, this);
			this.collection.on('sync', this.render, this);
		},

		render: function() {
			var self = this;
			this.$el.html(this.template());
			this.slides = [];
			this.collection.each(function(slide) {
				if (!slide.get('visible'))
					return;

				var view = new Switcharoo.Info.view({model: slide, template: '#slide-info'});
				self.slides.push(view);
				view.render();
			});
			this.slides.push(this.twitter());
			//this.slides.push(this.instagram());
			this.start();
			return this.el;
		},

		twitter: function() {
			var model = new Switcharoo.Twitter.model();
			var view = new Switcharoo.Twitter.view({model: model});
			model.fetch();
			return view;
		},

		start: function() {
			this.current = -1;
			var slide = this.getNext();
			this.$el.find('.slide').html(slide.html());
			slide.animatableElements().velocity('transition.slideUpIn', {stagger: 50});
			Backbone.Events.trigger('render:done');
		},

		slideNext: function() {
			var _container = this;
			this.$el.velocity({
				translateX: ['-50%', 0]
			}, {
				easing: 'ease-in-out',
				duration: this.animationDuration,
				complete: function() {
					var self = $(this);
					var next = self.find('.slide:nth-child(1)');
					self.remove('.slide:nth-child(1)');
					next.html(_container.getNext().html());
					self.append(next);
					self.removeAttr('style');
					Backbone.Events.trigger('slide:next:done');
				}
			})
		},

		slideInNext: function() {
			var self = this;
			this.getCurrent().animatableElements().velocity('transition.slideUpOut', {
				stagger: 50,
				complete: function() {
					var next = self.getNext();
					self.$el.find('.slide').html(next.html());
					next.animatableElements().velocity('transition.slideUpIn', {stagger: 50});
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
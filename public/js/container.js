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
			Backbone.Events.on('slide:next', this.next, this);
			this.collection.on('sync', this.render, this);
		},

		render: function() {
			var self = this;
			this.$el.html(this.template());
			//var model = this.model.toJSON().slides;
			this.slides = [];
			this.collection.each(function(slide) {
				//var model = new Switcharoo.Info.model({id: slide.id});
				var view = new Switcharoo.Info.view({model: slide, template: '#slide-info'});
				self.slides.push(view);
				view.render();
			});
			/*model.forEach(function(s) {
				var Slide = resolveType(s);
				if (!Slide)
					return;

				var m = new Slide.model({id: s.id});
				var slide = new Slide.view({ model: m });
				slide.on('render:done', self.slideReady, self);
				slides.push(slide);
			});*/
			//this.slidesReady = 0;
			/*this.slides.forEach(function(slide) {
				slide.model.fetch();
			});*/
			//this.$el.html(this.template());
			console.log(this.slides);
			this.start();
			return this.el;
		},

		/*slideReady: function() {
			this.slidesReady++;

			if (this.slidesReady >= this.slides.length) {
				this.$el.find('.slide:nth-child(1)').html(this.slides[0].html());
				this.$el.find('.slide:nth-child(2)').html(this.slides[1].html());
				this.current = 1;
				Backbone.Events.trigger('render:done');
			}
		},*/

		start: function() {
			this.$el.find('.slide:nth-child(1)').html(this.slides[0].html());
			this.$el.find('.slide:nth-child(2)').html(this.slides[1].html());
			this.current = 1;
			Backbone.Events.trigger('render:done');
		},

		next: function() {
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

		getNext: function() {
			var current = this.current;
			if (current == this.slides.length - 1)
				this.current = 0;
			else
				this.current += 1;

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
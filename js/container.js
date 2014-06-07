(function(Switcharoo, Backbone) {
	"use strict";

	var ContainerView = Backbone.View.extend({

		initialize: function(options) {
			this.template = options.template;
			this.animationDuration = options.animationDuration || 500;
			Backbone.Events.on('slide:next', this.next, this);
		},

		render: function() {
			var template = $(this.template).html();
			this.$el.html(Handlebars.compile(template)());
		},

		loadSlides: function() {
			var slides = [];
			[Switcharoo.Twitter, Switcharoo.Instagram].forEach(function(slide) {
				var view = new slide();
				view.render();
				slides.push(view);
			});
			console.log(this.$el.find('.slide:nth-child(1)'));
			this.$el.find('.slide:nth-child(1)').html(slides[0].html());
			this.$el.find('.slide:nth-child(2)').html(slides[1].html());
			this.slides = slides;
		},

		next: function() {
			this.$el.velocity({
				translateX: ['-50%', 0]
			}, {
				easing: 'ease-in-out',
				duration: this.animationDuration,
				complete: function() {
					var self = $(this);
					var next = self.find('.slide:nth-child(1)');
					self.remove('.slide:nth-child(1)');
					self.append(next);
					self.removeAttr('style');
					Backbone.Events.trigger('slide:next:done');
				}
			})
		}

	});

	Switcharoo.ContainerView = ContainerView;

})(window.Switcharoo = window.Switcharoo || {}, window.Backbone);
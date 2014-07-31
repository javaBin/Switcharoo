(function(Switcharoo, Backbone) {
	"use strict";

	var Progress = Backbone.View.extend({

		initialize: function(options) {
			this.duration = options.duration || 10000;
			this.shouldAnimate = options.shouldAnimate;
			Backbone.Events.on('slide:next:done', this.start, this);
		},

		start: function() {
			if (this.shouldAnimate)
				this.animate();
			else
				this.countdown();
		},

		animate: function() {
			this.$el.velocity({
				width: '100%'
			}, {
				easing: 'linear',
				duration: this.duration,
				complete: function() {
					$(this).css('width', 0);
					Backbone.Events.trigger('slide:next');
				}
			});
		},

		countdown: function() {
			setTimeout(function() {
				Backbone.Events.trigger('slide:next');
			}, this.duration);
		}
	});

	Switcharoo.Progress = Progress;

})(window.Switcharoo = window.Switcharoo || {}, window.Backbone);
(function(Switcharoo, Backbone) {
	"use strict";

	var Progress = Backbone.View.extend({

		initialize: function(options) {
			this.duration = options.duration || 5000;
			Backbone.Events.on('slide:next:done', this.start, this);
		},

		start: function() {
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
		}
	});

	Switcharoo.Progress = Progress;

})(window.Switcharoo = window.Switcharoo || {}, window.Backbone);
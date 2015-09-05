(function(Switcharoo, Backbone) {
	"use strict";

    var ANIMATE_ID = 1337;

	var Timer = Backbone.View.extend({

		initialize: function(options) {
			this.duration = options.duration || 4000;
			this.shouldAnimate = options.shouldAnimate;
			Backbone.Events.on('slide:next:done', this.start, this);
			Backbone.Events.on('key:left', this.prev, this);
			Backbone.Events.on('key:right', this.next, this);
			Backbone.Events.on('key:space', this.toggle, this);
		},

		start: function() {
			if (this.shouldAnimate)
				this.animate();
			else
				this.countdown();
		},

		animate: function() {
            this.timeoutID = ANIMATE_ID;
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
			this.timeoutID = setTimeout(function() {
				Backbone.Events.trigger('slide:next');
			}, this.duration);
		},

		prev: function() {
			console.log('prev');
		},

		next: function() {
			clearTimeout(this.timeoutID);
			Backbone.Events.trigger('slide:next');
			console.log('Next slide');
		},

		toggle: function() {
			if (typeof this.timeoutID === 'undefined')
				this.play();
			else
				this.pause();
		},

		pause: function() {
            if (this.timeoutID === ANIMATE_ID)
                this.$el.velocity('stop');

			clearTimeout(this.timeoutID);
            this.timeoutID = undefined;
			console.log('Paused playback');
		},

		play: function() {
			if (typeof this.timeoutID !== 'undefined')
				return;

			this.start();
			console.log('Continued playback');
		}
	});

	Switcharoo.Timer = Timer;

})(window.Switcharoo = window.Switcharoo || {}, window.Backbone);
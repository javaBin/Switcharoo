(function(Switcharoo, Backbone) {

	var app = Backbone.View.extend({
		
		initialize: function(options) {
			this.template = Handlebars.compile($(options.template).html());
		},

		render: function() {
			this.$el.html(this.template());

			this.renderProgress();
			this.renderSlides();
		},

		renderSlides: function() {
			var slides = new Switcharoo.Container.collection();
			var container = new Switcharoo.Container.view({el: this.$el.find('.slide'), animationDuration: 250, collection: slides});
			slides.fetch({reset:true});

			this.container = container;
		},

		renderProgress: function() {
			var progress = new Switcharoo.Progress({el: $('.progress'), duration: 4000, shouldAnimate: false});
			Backbone.Events.on('render:done', progress.start, progress);

			this.progress = progress;
		}

	});

	Switcharoo.App = app;

})(window.Switcharoo = window.Switcharoo || {}, window.Backbone);
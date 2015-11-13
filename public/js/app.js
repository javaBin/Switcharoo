import Backbone from 'backbone';
import Container from './container';
import Timer from './timer';
import Keyhandler from './keyhandler';
import $ from 'jquery'
import template from './container.hbs';
import less from '../css/app.less';

var app = Backbone.View.extend({
	
	initialize: function(options) {
        console.log(this.$el);
		this.template = template;//Handlebars.compile($(options.template).html());
		window.slideDuration = 15000;
	},

	render: function() {
		this.$el.html(this.template());

		this.renderProgress();
		this.renderSlides();
	},

	renderSlides: function() {
		var slides = new Container.collection();
		var container = new Container.view({el: this.$el.find('.slide'), animationDuration: 250, collection: slides});
		slides.fetch({reset:true});

		this.container = container;
	},

	renderProgress: function() {
		var progress = new Timer({el: $('.progress'), duration: window.slideDuration, shouldAnimate: false});
		Backbone.Events.on('render:done', progress.start, progress);

		this.progress = progress;
	},

	pause: function() {
		this.progress.pause();
	},

	play: function() {
		this.progress.play();
	}

});

// Switcharoo.App = app;
console.log($('.container'));
var app = new app({el: $('.container')});
app.render();
window.app = app;

var keyHandler = new Keyhandler($(document));
keyHandler.listen();

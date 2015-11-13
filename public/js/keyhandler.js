import Backbone from 'backbone';

var LEFT = 37;
var RIGHT = 39;
var SPACE = 32;

function Keyhandler(container) {
	this.container = container;
}

Keyhandler.prototype.listen = function() {
	this.container.keydown(function(ev) {
		
		switch (ev.keyCode) {
			case LEFT:
				Backbone.Events.trigger('key:left');
				break;
			case RIGHT:
				Backbone.Events.trigger('key:right');
				break;
			case SPACE:
				Backbone.Events.trigger('key:space');
				break;
		}

	});
};

export default Keyhandler;

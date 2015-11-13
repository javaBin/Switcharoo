import Backbone from 'backbone';

var Slide = Backbone.View.extend({

	initialize: function(options) {
		this.template = options.template;//Handlebars.compile($(options.template).html());
	},

	render: function() {
		var model = this.model.toJSON();
		this.$el.html(this.template(model));
		return this.el;
	},

	html: function() {
		return this.el;
	},

	shouldShow: function() {
		return true;
	}
	
});

export default Slide;

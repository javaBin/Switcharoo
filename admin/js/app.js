(function(Admin, Backbone, Handlebars) {

	var view = Backbone.View.extend({

		initialize: function(options) {
			this.template = Handlebars.compile($(options.template).html());
			this.slides = new Admin.Slides.view({collection: new Admin.Slides.collection(), template: '#slides-template'});
			this.slideEdit = new Admin.Slide.view({template: '#slide-edit-template'});
			Backbone.Events.on('slide:edit', this.edit, this);
			Backbone.Events.on('slide:edit:close', this.cancelEdit, this);
		},

		render: function() {
			this.$el.html(this.template());
			this.assign(this.slides, '.slides');
			return this.el;
		},

		assign: function(view, selector) {
			view.setElement(this.$(selector)).render();
		},

		edit: function(slide) {
			this.slideEdit.model = slide;
			this.assign(this.slideEdit, '.slide-edit');
		},

		cancelEdit: function() {
			this.slideEdit.model = undefined;
			this.$el.find('.slide-edit').empty();
		}


	});

	Admin.App = {
		view: view
	};

})(window.Admin = window.Admin || {}, window.Backbone, window.Handlebars);
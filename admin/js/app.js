(function(Admin, Backbone, Handlebars) {

	var view = Backbone.View.extend({

		events: {
			'click .text-slide': 'createTextSlide',
			'click .image-slide': 'createImageSlide'
		},

		initialize: function(options) {
			this.template = Handlebars.compile($(options.template).html());
			this.slides = new Admin.Slides.view({collection: new Admin.Slides.collection(), template: '#slides-template'});
			this.textSlideEdit = new Admin.Slide.view({template: '#slide-edit-text-template'});
			this.imageSlideEdit = new Admin.Slide.view({template: '#slide-edit-image-template'});
			Backbone.Events.on('slide:edit-text', this.edit, this);
			Backbone.Events.on('slide:edit-image', this.editImage, this);
			Backbone.Events.on('slide:edit:close', this.closeEdit, this);
			Backbone.Events.on('slide:remove', this.remove, this);
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
			this.textSlideEdit.model = slide;
			this.assign(this.textSlideEdit, '.slide-edit');
		},

		closeEdit: function() {
			this.textSlideEdit.model = undefined;
			this.$el.find('.slide-edit').empty();
			this.slides.collection.fetch();
		},

		createTextSlide: function() {
			var model = new Admin.Slide.model();
			model.set('type', 'text');
			this.textSlideEdit.model = model;
			this.assign(this.textSlideEdit, '.slide-edit');
		},

		editImage: function(slide) {
			this.imageSlideEdit.model = slide;
			this.assign(this.imageSlideEdit, '.slide-edit');
		},

		closeEditImage: function() {
			this.imageSlideEdit.model = undefined;
			this.$el.find('.slide-edit').empty();
			this.slides.collection.fetch();
		},

		createImageSlide: function() {
			var model = new Admin.Slide.model();
			model.set('type', 'image');
			this.imageSlideEdit.model = model;
			this.assign(this.imageSlideEdit, '.slide-edit');
		},

		remove: function(slide) {
			slide.model.destroy();
			this.slides.collection.remove(slide);
		}

	});

	Admin.App = {
		view: view
	};

})(window.Admin = window.Admin || {}, window.Backbone, window.Handlebars);
(function(Admin, Backbone, Handlebars) {

	var view = Backbone.View.extend({

		events: {
			'click .text-slide': 'createTextSlide',
			'click .image-slide': 'createImageSlide'
		},

		initialize: function(options) {
			this.template = Handlebars.compile($(options.template).html());
			this.slides = new Admin.Slides.view({collection: new Admin.Slides.collection(), template: '#slides-template'});
            this.settings = new Admin.Settings.view({collection: new Admin.Settings.collection(), template: '#settings-template'});
			Backbone.Events.on('slide:edit', this.edit, this);
			Backbone.Events.on('slide:edit:close', this.close, this);
			Backbone.Events.on('slide:remove', this.remove, this);
		},

		render: function() {
			this.$el.html(this.template());
			this.assign(this.slides, '.slides');
            this.assign(this.settings, '.settings');
			return this.el;
		},

		assign: function(view, selector) {
			var container = $('<div></div>');
			$(selector).append(view.setElement(container).render());
		},

		edit: function(slide) {
			var template = slide.get('type') === 'text'
				? '#slide-edit-text-template'
				: '#slide-edit-image-template'
			this.slideEdit = new Admin.Slide.view({template: template});
			this.slideEdit.model = slide;
			this.assign(this.slideEdit, '.slide-edit');
		},

		close: function() {
			this.slideEdit.remove();
			this.slides.collection.fetch();
		},

		editText: function(slide) {
			this.slideEdit = new Admin.Slide.view({template: '#slide-edit-text-template'});
			this.slideEdit.model = model;
			this.assign(this.slideEdit, '.slide-edit');
		},

		editImage: function(slide) {
			this.imageSlideEdit.model = slide;
			this.assign(this.imageSlideEdit, '.slide-edit');
		},

		createTextSlide: function() {
			this.slideEdit = new Admin.Slide.view({template: '#slide-edit-text-template'});
			var model = new Admin.Slide.model();
			model.set('type', 'text');
			this.slideEdit.model = model;
			this.assign(this.slideEdit, '.slide-edit');
		},

		createImageSlide: function() {
			this.slideEdit = new Admin.Slide.view({template: '#slide-edit-image-template'});
			console.log('create image');
			var model = new Admin.Slide.model();
			model.set('type', 'image');
			this.slideEdit.model = model;
			this.assign(this.slideEdit, '.slide-edit');
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
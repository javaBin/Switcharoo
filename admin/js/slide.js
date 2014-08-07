(function(Admin, Backbone, Handlebars) {

	var view = Backbone.View.extend({

		tagName: 'li',

		events: {
			'click .visible': 'toggleVisible',
			'click .action-edit': 'edit',
			'click .action-delete': 'remove',
			'click .save': 'save',
			'click .close': 'close',
			'change .image-input': 'uploadImage'
		},

		initialize: function(options) {
			this.template = Handlebars.compile($(options.template).html());
			if (this.model)
				this.model.on('change', this.render, this);
		},

		render: function() {
			var model = this.model.toJSON()
			model.visible = model.visible.toString();
			this.$el.html(this.template(model));
			return this.el;
		},

		toggleVisible: function(event) {
			this.model.set({'visible': !this.model.get('visible')});
			this.model.save();
		},

		edit: function(event) {
			var e = 'slide:' + (this.model.get('type') === 'image'
				? 'edit-image'
				: 'edit-text');
			console.log(e);
			Backbone.Events.trigger(e, this.model);
		},

		remove: function(event) {
			if (!confirm("Do you really want to delete the slide \"" + this.model.get('title') + "\""))
				return;
			
			Backbone.Events.trigger('slide:remove', this);
		},

		save: function(event) {
			if (event)
				event.preventDefault();

			var body = this.model.get('type') === 'image'
				? this.$el.find('.image-link').text()
				: this.$el.find('textarea[name="body"]').val()

			this.model.set({
				'title': this.$el.find('input[name="title"]').val(),
				'body': body
			});
			this.model.save();
			Backbone.Events.trigger('slide:edit:close');
		},

		close: function(event) {
			Backbone.Events.trigger('slide:edit:close');
		},

		uploadImage: function(event) {
			event.preventDefault();
			var self = this;
			var formData = new FormData(this.$el.find('.upload-form')[0]);
			$.ajax({
				url: '/image',
				type: 'POST',
				xhr: function() {
					var myXhr = $.ajaxSettings.xhr();
					return myXhr;
				},
				success: function(res) {
					self.$el.find('.image-link')
						.attr('href', res.filepath)
						.text(res.filepath);
				},
				error: function(xhr) {
					console.log(xhr);
				},
				data: formData,
				cache: false,
				contentType: false,
				processData: false
			})
		}
	});

	var model = Backbone.Model.extend({

		urlRoot: '/slides',

		idAttribute: '_id',

		defaults: {
			'title': '',
			'body': '',
			'background': '',
			'visible': false
		}

	});

	Admin.Slide = {
		view: view,
		model: model
	};

})(window.Admin = window.Admin || {}, window.Backbone, window.Handlebars);
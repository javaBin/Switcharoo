(function(Switcharoo, Backbone) {
	"use strict";

	var TEN_MINUTES = 1000 * 60 * 10;
	var TWO_MINUTES = 1000 * 60 * 2;
    var TEN_SECS = 1000 * 10;

	var view = Backbone.View.extend({

        isAnimatedOut: false,

		initialize: function(options) {
			this.animationDuration = options.animationDuration || 500;
			Backbone.Events.on('slide:next', this.slideInNext, this);
			this.collection.once('sync', this.render, this);
			this.getSlides = false;
			this.getProgram = false;
			this.getTwitter = false;
			this.getInstagram = false;
		},

		render: function() {
			var slides = this.renderInfo();
			this.slides = slides;
			var special = this.renderSpecial();
			this.special = special;
			this.collection.on('sync', this.rerender, this);
			this.start();
		},

		rerender: function() {
			if (this.newSlides)
				delete this.newSlides;

			this.newSlides = this.renderInfo();
		},

		renderInfo: function() {
			var slides = [];
			this.collection.each(function(slide) {
				if (!slide.get('visible'))
					return;

				var template = slide.get('type') === 'image' ? '#slide-image-info' : '#slide-text-info';
				var view = new Switcharoo.Info.view({model: slide, template: template});
				slides.push(view);
				view.render();
			});

            if (slides.length === 1)
                slides[0].animatableElements().css('opacity', 1);

			return slides;
		},

		renderSpecial: function() {
			var special = [
				this.program(),
				this.twitter(),
				this.instagram()
			];
			return special;
		},

		program: function() {
			if (this.programView)
				delete this.programView;

			var model = new Switcharoo.Program.model();
			var view = new Switcharoo.Program.view({model: model, template: '#program'});
			this.programView = view;
			model.fetch();
			return view;
		},

		twitter: function() {
			if (this.twitterView)
				delete this.twitterView;

			var model = new Switcharoo.Twitter.model();
			var view = new Switcharoo.Twitter.view({model: model, template: '#twitter'});
			this.twitterView = view;
			model.fetch();
			return view;
		},

		instagram: function() {
			if (this.instagramView)
				delete this.instagramView;

			var model = new Switcharoo.Instagram.model();
			var view = new Switcharoo.Instagram.view({model: model, template: '#instagram'});
			this.instagramView = view;
			model.fetch();
			return view;
		},

		start: function() {
			this.current = -1;
			var slide = this.getNext();
			this.$el.html(slide.html());
			slide.animateIn().velocity('transition.slideUpIn');
			slide.trigger('visible');
			Backbone.Events.trigger('render:done');
			this.startTimers();
		},

		startTimers: function() {
			var self = this;
			setInterval(function() { self.getSlides = true; }, TWO_MINUTES);
			setInterval(function() { self.getProgram = true; }, TWO_MINUTES);
			setInterval(function() { self.getTwitter = true; }, TEN_MINUTES);
			setInterval(function() { self.getInstagram = true; }, TEN_MINUTES);
		},

		slideInNext: function() {
			var self = this;

            function complete() {
                if (self.nextIndex() === 0)
                    self.setNext();

                var next;
                do {
                    next = self.getNext();
                } while ( next && !next.shouldShow())

                if (self.nextIndex() === 0 && self.getSlides) {
                    self.collection.fetch();
                    self.getSlides = false;
                }

                if (self.nextIndex() === 1 || self.numberOfSlides() === 1) {
                    if (self.getProgram) {
                        self.programView.model.fetch();
                        self.getProgram = false;
                    }

                    if (self.getTwitter) {
                        self.twitterView.model.fetch();
                        self.getTwitter = false;
                    }

                    if (self.getInstagram) {
                        self.instagramView.model.fetch();
                        self.getInstagram = false;
                    }
                }

                self.$el.html(next.html());
                if (self.numberOfSlides() !== 1 || self.isAnimatedOut) {
                    self.isAnimatedOut = false;
                    next.animateIn().velocity('transition.slideUpIn');
                }
                Backbone.Events.trigger('slide:next:done');
                next.trigger('visible');
            }

            if (this.numberOfSlides() === 1) {
                complete();
            } else {
                self.isAnimatedOut = true;
    			this.getSlide().animateOut().velocity('transition.slideUpOut', {
    				complete: complete
    			});
            }
		},

		setNext: function() {
			if (this.newSlides) {
				delete this.slides;
				this.slides = this.newSlides;
			}
			this.current = -1;
			delete this.newSlides;
		},

        getSpecial: function(index) {
            var special = _.filter(this.special, function(special) {
                return special.shouldShow();
            });
            return special[index];
        },

		getSlide: function(index) {
			if (typeof index === 'undefined')
				index = this.current;

			if (index < this.slides.length)
				return this.slides[index];
			
			return this.getSpecial(index - this.slides.length);
		},

		nextIndex: function() {
			var max = this.numberOfSlides();
			return (this.current + 1) % max;
		},

		getNext: function() {
			var next = this.nextIndex();
			var nextSlide = this.getSlide(next);
			this.current = next;
			return nextSlide;
		},

        numberOfSlides: function() {
            var special = _.reduce(this.special, function(mem, special) {
                return mem + (special.shouldShow() ? 1 : 0);
            }, 0);
            return this.slides.length + special;
        }

	});

	var model = Backbone.Model.extend({
		url: '/slides'
	});

	var collection = Backbone.Collection.extend({
		model: model,

		comparator: 'index',

		url: '/slides'
	});

	Switcharoo.Container = {
		view: view,
		model: model,
		collection: collection
	};

})(window.Switcharoo = window.Switcharoo || {}, window.Backbone);
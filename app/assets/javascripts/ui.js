(function($) {
	'use strict'

	$(document).on('click', '.not-implemented', function(e) {
		e.preventDefault();
		alert('Not implemented');
	});

	$(document).on('click', '.siteheader-toggle', function(e) {
		e.preventDefault();
		var usernav = $('.usernav');
		usernav.toggleClass('is-active');

		if (usernav.hasClass('is-active')) {
			setTimeout(function() {
				$(document).one('click', function(e) {
					usernav.removeClass('is-active');
				});
			}, 100);
		}
	});

	$(document).on('click', '.alert-close', function(e) {
		e.preventDefault();
		$(this).closest('.alert').fadeOut(function() {
			$(this).remove();
		})
	});

	$(document).on('focusin', 'input', function(e) {
		$(this).parent('.input').addClass('has-focus');
	});

	$(document).on('focusout', 'input', function(e) {
		$(this).parent('.input').removeClass('has-focus');
	});

})(jQuery);
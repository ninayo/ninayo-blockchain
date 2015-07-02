(function($) {
	'use strict'

	$('html').addClass('js');

	var method;
	var noop = function () {};
	var methods = [
		'assert', 'clear', 'count', 'debug', 'dir', 'dirxml', 'error',
		'exception', 'group', 'groupCollapsed', 'groupEnd', 'info', 'log',
		'markTimeline', 'profile', 'profileEnd', 'table', 'time', 'timeEnd',
		'timeline', 'timelineEnd', 'timeStamp', 'trace', 'warn'
	];
	var length = methods.length;
	var console = (window.console = window.console || {});

	while (length--) {
		method = methods[length];

		// Only stub undefined methods.
		if (!console[method]) {
			console[method] = noop;
		}
	}

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
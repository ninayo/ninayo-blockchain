(function($) {

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

})(jQuery);
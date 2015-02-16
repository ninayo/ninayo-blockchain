(function($) {

	$(document).on('click', '.siteheader-toggle', function(e) {
		e.preventDefault();
		$('.usernav').toggleClass('is-active');
	});

})(jQuery);
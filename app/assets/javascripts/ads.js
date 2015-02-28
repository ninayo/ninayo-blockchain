(function($) {

	$(document).on('click', '.filter-toggle', function(e) {
		e.preventDefault();
		$('.wrapper').toggleClass('show-filter');

		$.cookie('show_filter', $('.wrapper').hasClass('show-filter'), { expires: 365, path: '/' });
	});

})(jQuery);
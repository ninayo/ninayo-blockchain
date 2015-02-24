(function($) {

	$(document).on('click', '.filter-toggle', function(e) {
		e.preventDefault();
		console.log('show-filter')

		$('.ads-wrapper').toggleClass('show-filter');
	});

})(jQuery);
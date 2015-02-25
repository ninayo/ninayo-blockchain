(function($) {

	$(document).on('click', '.filter-toggle', function(e) {
		e.preventDefault();
		console.log('show-filter')

		$('.ads-wrapper').toggleClass('show-filter');
		$('.map').toggleClass('show-filter');

		if(window.admap) {
			google.maps.event.trigger(window.admap, 'resize');
			
		}
	});

})(jQuery);
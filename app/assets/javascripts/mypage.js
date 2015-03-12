(function($) {
	$(document).on('page:load', function() {
		$('.ads-table').table().data('table').refresh();
	});
})(jQuery);
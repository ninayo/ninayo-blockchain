(function($) {
	'use strict'

	$(document).on('page:load', function() {
		var adsTable = $('.ads-table');

		if (adsTable.length) {
			adsTable.table().data('table').refresh();
		}

	});
})(jQuery);
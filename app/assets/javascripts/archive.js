(function($) {
	'use strict'

	$(document).on('change', '#ad_buyer_id', function(e) {
		var select = $(this);

		$('#rate-buyer').toggleClass('is-hidden', select.val());
	});


})(jQuery);
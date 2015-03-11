(function($) {

	$(document).on('ready page:load', function() {
		if ($('body').hasClass('ads-new')) {
			findPosition();
		}
	});

	var position;

	var findPosition = function() {
		if (!'geolocation' in navigator) {
			return;
		}

		var watchID = navigator.geolocation.watchPosition(function(pos) {
			position = pos;
			$('#ad_lat').val(pos.coords.latitude);
			$('#ad_lng').val(pos.coords.longitude);
		});

	};

})(jQuery);
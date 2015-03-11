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

		function geo_success(pos) {
			position = pos;
			$('#ad_lat').val(pos.coords.latitude);
			$('#ad_lng').val(pos.coords.longitude);
		}

		function geo_error(error) {
			 alert('ERROR(' + error.code + '): ' + error.message);
		}

		var geo_options = {
			enableHighAccuracy: true,
			maximumAge        : 30000,
			timeout           : 27000
		};

		var watchID = navigator.geolocation.watchPosition(geo_success, geo_error, geo_options);

	};

})(jQuery);
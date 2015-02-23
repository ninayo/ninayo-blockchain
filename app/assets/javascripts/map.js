(function($) {
	'use strict'

	var map,
		mapDiv;

	$(document).on('ready page:load', function() {

	 	mapDiv = $('#admap');
	 	if (!mapDiv.length) {
	 		return;
	 	}

	 	if (typeof google != 'undefined' && google.maps) {
			initMap();
	 	}
	});

	var initMap = function() {
		console.log('initMap')
		map = new google.maps.Map(document.getElementById('admap'), {
			zoom: 8,
			center: new google.maps.LatLng(-34.397, 150.644)
		});
		isInitialized = true;
	}

})(jQuery);
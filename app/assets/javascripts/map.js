(function($) {
	'use strict'

	var map,
		mapDiv,
		isInitialized = false;

	window.admap = map;

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
		map = new google.maps.Map(document.getElementById('admap'), {
			zoom: 8,
			center: new google.maps.LatLng(-7.458111, 35.991116),
			mapTypeId: google.maps.MapTypeId.TERRAIN
		});

		// google.maps.event.addDomListener(map, 'tilesloaded', function(){
		// 	if($('.map-controls').length == 0){
		// 		$('div.gmnoprint').last().parent().wrap('<div class="map-controls" />');
		// 	}
		// });
		isInitialized = true;
	}

})(jQuery);
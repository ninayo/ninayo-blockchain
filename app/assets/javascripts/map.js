(function($) {
	'use strict'

	var map,
		mapDiv,
		isInitialized = false,
		resizeTimeout,
		markers = [],
		infoWindow;


	$(document).on('ready page:load', function() {

	 	mapDiv = $('#admap');
	 	if (!mapDiv.length) {
	 		return;
	 	}

	 	if (typeof google != 'undefined' && google.maps) {
			initMap();
	 	}
	});



	$(document).on('change', '.map #filter-form', postFilterForm);
	$(document).on('submit', '.map #filter-form', function(e) {
		e.preventDefault();
		postFilterForm();
	});


	var initMap = function() {
		map = new google.maps.Map(document.getElementById('admap'), {
			zoom: 6,
			center: new google.maps.LatLng(-7.458111, 35.991116),
			mapTypeId: google.maps.MapTypeId.TERRAIN
		});

		// google.maps.event.addDomListener(map, 'tilesloaded', function(){
		// 	if($('.map-controls').length == 0){
		// 		$('div.gmnoprint').last().parent().wrap('<div class="map-controls" />');
		// 	}
		// });
		isInitialized = true;

		postFilterForm();

		$(window).on('resize', function() {

			if (resizeTimeout) {
				clearTimeout(resizeTimeout);
			}

			resizeTimeout = setTimeout(function() {
				google.maps.event.trigger(map, 'resize');
			}, 500);
		});
	};

	var addMarkers = function(data) {

		for(var i = 0, length = markers.length; i < length; i++) {
			markers[i].setMap(null);
			markers[i] = null;
		}

		markers.splice(0, markers.length);

		for(var i = 0, length = data.length; i < length; i++) {
			var marker = createMarker(data[i]);
			markers.push(marker);
		}
	};

	var createMarker = function(data) {
		var latLng = new google.maps.LatLng(data.lat, data.lng);
		var marker = new google.maps.Marker({
			position: latLng,
			map: map,
			title: data.title,
		});
		marker.ad = data;

		google.maps.event.addListener(marker, 'click', function(e) {
			createOrUpdateInfoWindow(marker);
		});

		return marker;
	};

	var createOrUpdateInfoWindow = function(marker) {
		if (!infoWindow) {
			infoWindow = new google.maps.InfoWindow();
		};
		infoWindow.setContent(createInfoWindowContent(marker.ad));
		infoWindow.open(map, marker);

		$.getJSON(marker.ad.url, function(data) {
			infoWindow.setContent(createInfoWindowContent(data));
		});
	};

	var createInfoWindowContent = function(ad) {
		var html = '<div class="infowindow-content">';
			html = html + '<h4>' + ad.title + '</h4>';
			if (ad.description) {
				html = html + '<p>' + ad.description + '</p>';
			};
			html = html + '<p>Price: ' + ad.price + ' /=</p>';
			if (ad.html_url) {
				html = html + '<p><a href="' + ad.html_url + '" class="button button-block">Show ad</a></p>';
			}
			html = html + '</div>';

		return html;
	};

	function postFilterForm() {
		var form = $('#filter-form');
		$.ajax({
			url: form.attr('action') + '.json',
			type: 'GET',
			accepts: 'application/json; charset=utf-8',
			data: form.serialize()
		}).done(function(data) {
			addMarkers(data);
		});
	};

})(jQuery);
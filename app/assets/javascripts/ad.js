(function($) {
	'use strict'

	var map,
		mapDiv,
		position,
		isInitialized = false,
		resizeTimeout,
		marker,
		hasPosition = false;

	$(document).on('ready page:load', function() {
		if ($('body').hasClass('ads-new')) {
			findPosition();
		}

		mapDiv = $('#positionmap-canvas ');
	 	if (!mapDiv.length) {
	 		return;
	 	}

	 	if (typeof google != 'undefined' && google.maps) {
			initMap();
	 	}
	});

	$(document).on('click', '.positionmap-toggle', function(e) {
		e.preventDefault();
		openModal();
	});

	function openModal() {
		$('.positionmap').addClass('is-active');

		setTimeout(function() {
			google.maps.event.trigger(map, 'resize');

			if (marker) {
				map.panTo(marker.getPosition());
			}
		}, 100)
	}

	function closeModal() {
		$('.positionmap').removeClass('is-active');
		setTimeout(function() {
			google.maps.event.trigger(map, 'resize');

			if (marker) {
				map.panTo(marker.getPosition());
			}
		}, 100)
	}

	$(document).on('keyup', function(e) {
		if (e.keyCode == 27) {
			closeModal();
		};
	});

	$(document).on('click', '.positionmap-confirm', function(e) {
		e.preventDefault();

		var latLng = marker.getPosition();
		updatePosition(latLng.lat(), latLng.lng());

		closeModal();
	});

	$(document).on('click', '.positionmap-close', function(e) {
		e.preventDefault();
		closeModal();
	});

	var findPosition = function() {
		if (!'geolocation' in navigator) {
			return;
		}

		function geo_success(pos) {
			position = pos;
			updatePosition(pos.coords.latitude, pos.coords.longitude);
			updateMarkerPosition(pos.coords.latitude, pos.coords.longitude);
			$('.positionmap').addClass('has-position');
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

	var updateMarkerPosition = function(lat, lng) {
		if (!marker) {
			createMarker(lat, lng);
		} else {
			marker.setPosition(new google.maps.LatLng(lat, lng));
		}
	};

	var updatePosition = function(lat, lng) {
		hasPosition = true;
		$('#ad_lat').val(lat);
		$('#ad_lng').val(lng);
	}

	var createMarker = function(lat, lng) {
		var latLng = new google.maps.LatLng(lat, lng);
		marker = new google.maps.Marker({
			position: latLng,
			map: map,
			draggable: true,
			animation: google.maps.Animation.DROP
		});

		google.maps.event.addListener(marker, 'dragend', function(e) {
			//updatePosition(e.latLng.lat(), e.latLng.lng());
		});

		map.panTo(latLng);
		map.setZoom(13);
	};



	var initMap = function() {
		map = new google.maps.Map(mapDiv[0], {
			zoom: 6,
			center: new google.maps.LatLng(-7.458111, 35.991116),
			mapTypeId: google.maps.MapTypeId.TERRAIN,
			disableDefaultUI: true,
			mapTypeControl: true,
			mapTypeControlOptions: {

			},
			zoomControl: true,
			zoomControlOptions: {},
			scaleControl: true,
			scaleControlOptions: {}
		});

		google.maps.event.addListener(map, 'click', function(e) {
			//updatePosition(e.latLng.lat(), e.latLng.lng());
			updateMarkerPosition(e.latLng.lat(), e.latLng.lng());
		});

		isInitialized = true;

		$(window).on('resize', function() {

			if (resizeTimeout) {
				clearTimeout(resizeTimeout);
			}

			resizeTimeout = setTimeout(function() {
				google.maps.event.trigger(map, 'resize');
			}, 500);
		});
	};

})(jQuery);
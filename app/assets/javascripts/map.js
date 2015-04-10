(function($) {
	'use strict'

	var map,
		mapDiv,
		isInitialized = false,
		resizeTimeout,
		mc,
		markers = [];


	$(document).on('ready page:load', function() {
		isInitialized = false;
	 	mapDiv = $('#admap');
	 	if (!mapDiv.length) {
	 		return;
	 	}

	 	if (typeof google != 'undefined' && google.maps) {
			initMap();
	 	}
	});

	$(document).on('click', '.infopanel-close', function(e) {
		e.preventDefault();
		$(this).closest('.map').removeClass('has-panel');
		setTimeout(function() {
			google.maps.event.trigger(map, 'resize');
		}, 300);
	});


	$(document).on('click', '.map #filter-form .pagenav-item', function(e) {
		e.preventDefault();

		var module = $(this).closest('.pagenav');
		module.find('.pagenav-item').removeClass('is-active');
		$(this).addClass('is-active');
		$('#ad_type').val($(this).val());

		postFilterForm();
	});

	$(document).on('change', '.map #filter-form select', postFilterForm);
	$(document).on('submit', '.map #filter-form', function(e) {
		e.preventDefault();
		postFilterForm();
	});


	var initMap = function() {
		map = new google.maps.Map(document.getElementById('admap'), {
			zoom: 6,
			center: new google.maps.LatLng(-7.458111, 35.991116),
			mapTypeId: google.maps.MapTypeId.TERRAIN,
			disableDefaultUI: true,
			mapTypeControl: true,
			scaleControl: true,
			zoomControl: true
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

		if (mc) {
			mc.clearMarkers();
		};

		markers.splice(0, markers.length);

		for(var i = 0, length = data.length; i < length; i++) {
			var marker = createMarker(data[i]);
			markers.push(marker);
		}

		mc = new MarkerClusterer(map, markers);
	};

	var createMarker = function(data) {
		var latLng = new google.maps.LatLng(data.lat, data.lng);
		var marker = new google.maps.Marker({
			position: latLng,
			//map: map,
			title: data.title,
		});
		marker.ad = data;

		google.maps.event.addListener(marker, 'click', function(e) {
			getAdInfo(marker);
		});

		return marker;
	};

	var getAdInfo = function(marker) {
		$('.infopanel-content').html('<h3 class="infopanel-heading">' + marker.ad.title + '</h3>');
		$('.map').addClass('has-panel');
		$('.infopanel .loader').addClass('is-active');

		$.get(marker.ad.url, function(data) {
			$('.infopanel-content').html(data);
			$('.infopanel .loader').removeClass('is-active');
		});
	}

	function postFilterForm() {

		var form = $('#filter-form'),
			formParams = form.serialize();

		$.ajax({
			url: form.attr('action') + '.json',
			type: 'GET',
			accepts: 'application/json; charset=utf-8',
			data: formParams
		}).done(function(data) {
			addMarkers(data);
			$('.pagenav-item').each(function() {
				this.search = '?' + formParams
			});
		});
	};

})(jQuery);
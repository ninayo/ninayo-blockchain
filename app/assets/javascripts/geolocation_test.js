(function($) {


  $(document).on('click', '#geolocationTest', function(e) {
    navigator.geolocation.getCurrentPosition(successCallback, errorCallback);
  });

  function successCallback(pos) {
    $('#geoLocationResult').append('<h4>Got a position!</h4>');
    $('#geoLocationResult').append('Latitude: ' + pos.coords.latitude + '<br>');
    $('#geoLocationResult').append('Longitude: ' + pos.coords.longitude + '<hr>');
  }

  function errorCallback(error) {
    $('#geoLocationResult').append('<h4>Error:</h4>' + JSON.stringify(error) + '<hr>');
  }

})(jQuery);

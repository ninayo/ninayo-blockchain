(function($) {
	'use strict'

	$(document).on('click', '.filter-toggle', function(e) {
		e.preventDefault();
		$('.wrapper').toggleClass('show-filter');

		$.cookie('show_filter', $('.wrapper').hasClass('show-filter'), { expires: 365, path: '/' });
	});

	$(document).on('change', '.ads-index #filter-form', function(e) {
		$(this).submit();
	});



	// $(window).off('resize.ads').on('resize.ads', setAdsWrapperHeight);

	// $(document).on('ready page:load', function() {
	// 	setAdsWrapperHeight();
	// });

	// var wrapperHeightTimeout;
	// function setAdsWrapperHeight() {

	// 	if (wrapperHeightTimeout) {
	// 		clearTimeout(wrapperHeightTimeout);
	// 	};

	// 	wrapperHeightTimeout = setTimeout(function() {
	// 		console.log('hej')
	// 		var adsWrapper = $('.ads-wrapper');

	// 		adsWrapper.removeAttr('style');
	// 		adsWrapper.css({
	// 			'min-height': calculatePageHeight()
	// 		});
	// 	}, 100);
	// }

	// function calculatePageHeight() {
	// 	var headerHeight = $('.siteheader').height(),
	// 		footerPosition = $('.sitefooter').offset().top;

	// 	return footerPosition - headerHeight;
	// }

})(jQuery);
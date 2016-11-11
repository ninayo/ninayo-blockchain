##this is the logic for dynamically filtering the dropdown results for region/district/ward according to
##the associations involved. the interpolation would get weird if we end up using locations with
##special characters in the name but there aren't any in TZ, which is convenient

jQuery -> 
	$('#ads_ward_id').parent().hide()
	districts = $('#ads_district_id').html()
	wards = $('#ads_ward_id').html()

	$('#ads_region_id').change ->
		region = $('#ads_region_id :selected').text()
		options = $(districts).filter("optgroup[label='#{region}']").html()
		if options
			$('#ads_district_id').html(options)
		else
			$('#ads_district_id').empty()

	$('#ads_district_id').change ->
		district = $('#ads_district_id :selected').text()
		options = $(wards).filter("optgroup[label='#{district}']").html()
		if options
			$('#ads_ward_id').html(options)
			$('#ads_ward_id').parent().show()
		else
			$('#ads_ward_id').empty()
			$('#ads_ward_id').parent().hide()

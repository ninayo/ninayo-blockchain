##this is the logic for dynamically filtering the dropdown results for region/district/ward according to
##the associations involved. the interpolation would get weird if we end up using locations with
##special characters in the name but there aren't any in TZ, which is convenient

jQuery -> 
	$('#ad_ward_id').parent().hide()
	districts = $('#ad_district_id').html()
	wards = $('#ad_ward_id').html()

	console.log(districts)

	$('#ad_region_id').change ->
		region = $('#ad_region_id :selected').text()
		options = $(districts).filter("optgroup[label='#{region}']").html()
		if options
			$('#ad_district_id').html(options)
		else
			$('#ad_district_id').empty()

	$('#ad_district_id').change ->
		district = $('#ad_district_id :selected').text()
		options = $(wards).filter("optgroup[label='#{district}']").html()
		if options
			$('#ad_ward_id').html(options)
			$('#ad_ward_id').parent().show()
		else
			$('#ad_ward_id').empty()
			$('#ad_ward_id').parent().hide()

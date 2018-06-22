##this is the logic for dynamically filtering the dropdown results for region/district/ward according to
##the associations involved. the interpolation would get weird if we end up using locations with
##special characters in the name but there aren't any in TZ, which is convenient

jQuery -> 
	$('#user_ward_id').parent().hide()
	districts = $('#user_district_id').html()
	wards = $('#user_ward_id').html()

	$('#user_region_id').change ->
		region = $('#user_region_id :selected').text()
		options = $(districts).filter("optgroup[label='#{region}']").html()
		if options
			$('#user_district_id').html(options)
		else
			$('#user_district_id').empty()

	$('#user_district_id').change ->
		district = $('#user_district_id :selected').text()
		options = $(wards).filter("optgroup[label='#{district}']").html()
		if options
			$('#user_ward_id').html(options)
			$('#user_ward_id').parent().show()
		else
			$('#user_ward_id').empty()
			$('#user_ward_id').parent().hide()

	$('#user_login').change ->
		val = $(this).val()
		form = $('#new_user')
		phoneRegExp = new RegExp(/^(\+[0-9][0-9][0-9]){0,1}[0-9]{8,9}$/);
		if phoneRegExp.test(val)
			$.ajax({
				url: form.attr('action') + '/sign_up.json',
				type: 'GET',
				accepts: 'application/json; charset=utf-8',
				data: {'phone': val},
				success: (data) ->
					$('#phone_taken').html($('#phone_taken').html().replace('REPLACEUSERLOGIN', encodeURIComponent(val)))
					$('#phone_taken').show()
			})
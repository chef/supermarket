$(function() {
	$("#deprecated").on('click', function(event) {
		var deprecatedData = {};

		if ($(this).is(":checked")){
			deprecatedData = { "deprecated": true }
		} else {
			deprecatedData = { "deprecated": false }
		}

		$.ajax({
	      type: "GET",
	      url: window.location.href,
	      data: deprecatedData,
	      dataType: "json",
	      success: function(response){
	      	$('.listing').html(response.html);

	      	if (response.number_of_cookbooks == 1) {
	      		$('#cookbooks_number').text(response.number_of_cookbooks).append(" Cookbook");
	      	} else {
	      		$('#cookbooks_number').text(response.number_of_cookbooks).append(" Cookbooks");
	      	}
	      },
	      error: function(xhr){
	      	return false;
	      }
    	});
	});
});

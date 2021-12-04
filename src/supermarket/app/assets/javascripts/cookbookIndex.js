$(function() {
	$("#deprecated").on('click', function(event) {
		if ($(this).is(":checked")){
			$.ajax({
	      type: "GET",
	      url: window.location.href,
	      data: { "deprecated": true },
	      dataType: "json",
	      success: function(response){
	      	$('.listing').html(response.html);
	      	// $('.title').html(response.number_of_cookbooks);
	      },
	      error: function(xhr){
	      	return false;
	      }
	    });
		} else {
			$.ajax({
	      type: "GET",
	      url: window.location.href,
	      dataType: "json",
	      success: function(response){
	      	$('.listing').html(response.html)
	      },
	      error: function(xhr){
	      	return false;
	      }
	    });
		}
		

	});
});
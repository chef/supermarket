$(function() {
  $(".show-cookbook-urls-manage").click(function(event) {
    event.preventDefault();
    $(".manage-cookbook-urls").show();
    $(".show-cookbook-urls-manage").hide();
    $(".cookbook-urls").hide();
  });

  $(".manage-cookbook-urls .edit_cookbook").on('ajax:success', function(event, data, status, xhr) {
    event.preventDefault();
    $(".form-errors").remove();
    $(".manage-cookbook-urls").hide();
    $(".show-cookbook-urls-manage").show();
    $(".source-url").attr("href", data.source_url)
    $(".issues-url").attr("href", data.issues_url)
    $(".cookbook-urls").show();

    // hide or show buttons based on content
    if (data.source_url == "" || data.source_url == null) {
      $(".source-url").hide();
    }
    else {
      if ($(".source-url")) {
        $(".source-url").show();
      }
      else {
        var url = '<a href="'+data.source_url+'" class="button source-url">View Source</div>'
        $(".cookbook-urls").prepend(url);
      }
    }

    if (data.issues_url == "" || data.issues_url == null) {
      $(".issues-url").hide();
    }
    else {
      if ($(".issues-url")) {
        $(".issues-url").show();
      }
      else {
        var url = '<a href="'+data.issues_url+'" class="button issues-url">View Issues</div>'
        $(".cookbook-urls").append(url);
      }
    }

    $(".page").append(
      '<div data-alert class="alert-box success"><div>The cookbook URLs were successfully saved.</div> <a href="#" class="close">&times;</a></div>'
    );

    $(document).foundation();
  });

  $(".manage-cookbook-urls .edit_cookbook").on('ajax:error', function(event, data, status, xhr) {
    event.preventDefault();
    $(".form-errors").remove();
    var errorsArray = $.parseJSON(data.responseText).errors;
    var errorsHTML = "<div class='form-errors'>";
    $.each(errorsArray, function(index, value) {
      errorsHTML += "<p class='error'>" + value + "</p>";
    });
    errorsHTML += "</div>";
    $(".page").append(
      '<div data-alert class="alert-box failure"><div>There was an error saving the cookbook URLs.</div> <a href="#" class="close">&times;</a></div>'
    );
    $(".manage-cookbook-urls").append(errorsHTML);
    $(document).foundation();
  });
});

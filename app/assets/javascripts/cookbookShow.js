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

$(function() {
  $(".show-cookbook-urls-manage").click(function(event) {
    event.preventDefault();
    $(".manage-cookbook-urls").show();
    $(".show-cookbook-urls-manage").hide();
    $(".cookbook-urls").hide();
  });

  $(".manage-cookbook-urls .edit_cookbook").on('ajax:success', function(event, data, status, xhr) {
    event.preventDefault(); // do I need this?
    $(".manage-cookbook-urls").hide();
    $(".show-cookbook-urls-manage").show();
    $(".source-url").attr("href", data.source_url)
    $(".issues-url").attr("href", data.issues_url)
    $(".cookbook-urls").show();

    $(".globalheader").append(
      '<div data-alert class="alert-box">Your cookbook URLs were successfully saved. <a href="#" class="close">&times;</a></div>'
    );
  });

  $(".manage-cookbook-urls .edit_cookbook").on('ajax:error', function(event, data, status, xhr) {
    event.preventDefault(); // do I need this?
    $(".globalheader").append(
      '<div data-alert class="alert-box">There was an error saving the cookbook URLs. <a href="#" class="close">&times;</a></div>'
    );
  });
});

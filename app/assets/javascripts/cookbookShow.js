$(function() {
  $(".show-cookbook-urls-manage").click(function(event) {
    event.preventDefault();
    $(".manage-cookbook-urls").show();
    $(".show-cookbook-urls-manage").hide();
    $(".cookbook-urls").hide();
  });

  $(".manage-cookbook-urls .edit_cookbook").on('ajax:success', function(event, data, status, xhr) {
    // here is where the AJAX will happen
    // todo
    // - replace the cookbook urls
    // - post the update
    // - display success or error message

    // do I need this?
    event.preventDefault();
    console.log(data);
    console.log(status);
    console.log(xhr);
    $(".manage-cookbook-urls").hide();
    $(".show-cookbook-urls-manage").show();
    $(".cookbook-urls").show();

    $(".globalheader").append(
      '<div data-alert class="alert-box">wow such save <a href="#" class="close">&times;</a></div>'
    );
  });

  $(".manage-cookbook-urls .edit_cookbook").on('ajax:error', function(event, data, status, xhr) {
    // do I need this?
    event.preventDefault();
    console.log(data);
    console.log(status);
    console.log(xhr);
    $(".globalheader").append(
      '<div data-alert class="alert-box">wow such error so sorry <a href="#" class="close">&times;</a></div>'
    );
  });
});

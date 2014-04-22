$(function() {
  $(".show-cookbook-urls-manage, .cancel-submit-urls").click(function(event) {
    event.preventDefault();
    $(".manage-cookbook-urls").slideToggle();
    $(".show-cookbook-urls-manage").fadeToggle();
    $(".cookbook-urls").fadeToggle();
  });

  $('a[data-remote]').on('ajax:success', function(e, data, status, xhr) {
    $(this).parent().remove();
  });
});

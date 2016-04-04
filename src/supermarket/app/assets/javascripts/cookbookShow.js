$(function() {
  $(".show-cookbook-urls-manage, .cancel-submit-urls").click(function(event) {
    event.preventDefault();
    $(".manage-cookbook-urls").slideToggle();
    $(".show-cookbook-urls-manage").toggleClass('active');
    $(".cookbook-urls").fadeToggle();
  });

  $('a[rel~="remove-cookbook-collaborator"]').on('ajax:success', function(e, data, status, xhr) {
    $(this).parents('.gravatar-container').remove();
  });
});

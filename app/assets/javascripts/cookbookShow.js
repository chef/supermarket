$(function() {
  $(".show-cookbook-urls-manage, .cancel-submit-urls").click(function(event) {
    event.preventDefault();
    $(".manage-cookbook-urls").slideToggle();
    $(".show-cookbook-urls-manage").fadeToggle();
    $(".cookbook-urls").fadeToggle();
  });

  $('a[rel~="remove-cookbook-collaborator"]').on('ajax:success', function(e, data, status, xhr) {
    $(this).parents('.gravatar-container').remove();
  });

  $('a[rel~="follow"], a[rel~="unfollow"]').on('click', function() {
    $(this).addClass('disabled');
  });

  $('body').delegate('a[rel~="follow"], a[rel~="unfollow"]', 'ajax:success', function(e, data, status, xhr) {
    $(this).parent().load(window.location.href + ' a[data-cookbook="' + $(this).data('cookbook') + '"]');
  });
});

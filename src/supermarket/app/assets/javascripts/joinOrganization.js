$(function() {
  /*
   * Adds a disabled class when the user clicks the button to join an
   * organization so they know a request is in progress
   */
  $('a[rel~="contributor-request"]').on('click', function() {
    $(this).addClass('disabled');
  });

  /*
   * Binds an ajax:success event to the join button and replaces
   * the button's parent with server-rendered HTML
   */
  $('body').delegate('.contribute .join', 'ajax:success', function(e, data, status, xhr) {
    $(this).parent().replaceWith(data)
  });
});

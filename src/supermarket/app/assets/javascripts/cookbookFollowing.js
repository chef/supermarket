$(function() {
  /*
   * Adds a disabled class when the user clicks a follow or unfollow button
   * so they know a request is in progress and they don't click follow or unfollow
   * twice.
   */
  $('a[rel~="follow"], a[rel~="unfollow"]').on('click', function() {
    $(this).addClass('disabled');
  });

  /*
   * Binds an ajax:success event to the cookbook partial follow button and replaces
   * the partial in question with server side rendered HTML.
   */
  $('body').delegate('.listing .follow', 'ajax:success', function(e, data, status, xhr) {
    var followCountId = '#' + $(this).data('cookbook') + '-follow-count';
    var followButtonId = '#' + $(this).data('cookbook') + '-follow-button';

    $(followCountId).replaceWith($(data).filter(followCountId));
    $(followButtonId).replaceWith($(data).filter(followButtonId));
  });

  /*
   * Binds an ajax:success event to the cookbook show follow button and replaces
   * the followbutton which includes the follow count with server side rendred HTML.
   */
  $('body').delegate('.cookbook_show .follow', 'ajax:success', function(e, data, status, xhr) {
    $('.followbutton').replaceWith(data);
  });
});

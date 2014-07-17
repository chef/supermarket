$(function() {
  /*
   * Track following and unfollowing cookbooks in Segment.IO
   *
   */
  var trackFollows = function(obj) {
    if (window.analytics) {
      var id = $(obj).attr('id');
      var txt;

      if (id == 'follow_cookbook') {
        txt = 'Followed Cookbook';
      } else {
        txt = 'Unfollowed Cookbook';
      }

      analytics.track(txt, {cookbook: $(obj).data('cookbook')});
    }
  };

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
    var cookbookId = '#' + $(this).data('cookbook');
    trackFollows(this);

    $.get(window.location.href, function(response) {
      $(cookbookId).replaceWith($(response).find(cookbookId));
    }, 'html');
  });

  /*
   * Binds an ajax:success event to the cookbook show follow button and replaces
   * the followbutton which includes the follow count with server side rendred HTML.
   */
  $('body').delegate('.cookbook_show .follow', 'ajax:success', function(e, data, status, xhr) {
    trackFollows(this);

    $.get(window.location.href, function(response) {
      $('.followbutton').replaceWith($(response).find('.followbutton'));
    }, 'html');
  });
});

$(function() {
  $(".more-info").click(function() {
    if ($(".announcement_banner_content").is(":hidden")) {
      $(".announcement_banner_content").slideDown(50);
    } else {
      $(".announcement_banner_content").slideUp(240);
    }
  });
});
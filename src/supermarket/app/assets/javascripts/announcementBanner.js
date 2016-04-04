$(function() {
  $(".announcement_banner_header").click(function() {
    if ($(".announcement_banner_content").is(":hidden")) {
      $(".announcement_banner_content").slideDown(300);
    } else {
      $(".announcement_banner_content").slideUp(240);
    }
  });
});

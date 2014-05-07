$(function() {
  $(".beta_banner_header").click(function() {
    if ($(".beta_banner_content").is(":hidden")) {
      $(".beta_banner_content").slideDown(300);
    } else {
      $(".beta_banner_content").slideUp(240);
    }
  });
});

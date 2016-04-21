var cancelIsClicked = false;

$("span.fa.fa-times").click(function(){
  cancelIsClicked = true;
});

$(function() {
  $(".announcement_banner_header").click(function() {
    if (cancelIsClicked) {
      $(".announcement_banner_header").hide();
    } else if($(".announcement_banner_content").is(":hidden")) {
      $(".announcement_banner_content").slideDown(300);
    } else {
      $(".announcement_banner_content").slideUp(240);
    }
  });
});
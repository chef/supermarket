$(function() {
  $(".show-cookbook-urls-manage, .cancel-submit-urls").click(function(event) {
    event.preventDefault();
    $(".manage-cookbook-urls").slideToggle();
    $(".show-cookbook-urls-manage").fadeToggle();
    $(".cookbook-urls").fadeToggle();
  });
});

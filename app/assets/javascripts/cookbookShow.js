$(function() {
  $(".show-cookbook-urls-manage").click(function(event) {
    event.preventDefault();
    $(".manage-cookbook-urls").show();
    $(".show-cookbook-urls-manage").hide();
    $(".cookbook-urls").hide();
  });
});

$(function() {
  $(".expand").click(function() {
    $('.contributor-' + $(this).data('id')).toggle();
  });
});

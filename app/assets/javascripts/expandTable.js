$(function() {
  $(".expand").click(function(event) {
    event.preventDefault();
    $('.contributor-' + $(this).data('id')).toggle();
  });
});

$(function() {
  $(".edit_invitation", ".edit_contributor").on("ajax:success", function(e, data, status, xhr) {
    $(this).addClass("success");
  });
});

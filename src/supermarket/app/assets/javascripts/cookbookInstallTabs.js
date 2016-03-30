$(function() {
  $(".persist-install-method dd a").click(function() {
    var href = $(this).attr("href");
    var preference = href.replace("#", "");

    $.ajax({
      type: "POST",
      url: $(".installs").data('update-url'),
      data: { "preference": preference },
      dataType: "json"
    });
  });
});


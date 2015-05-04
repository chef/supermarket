$(function() {
  if($.cookie('advancedSearch') == 'on'){
    $(".advanced_search_body").show();
  }

  $(".advanced_search_toggle span").click(function() {

    if ($(".advanced_search_body").is(":hidden")) {
      $(".advanced_search_body").slideDown(300);
      $.cookie('advancedSearch' ,'on')
      $("#toggle-arrow").removeClass("fa-chevron-down");
      $("#toggle-arrow").addClass("fa-chevron-up");
    } else {
      $(".advanced_search_body").slideUp(240);
      $.cookie('advancedSearch', 'off');
      $('input:checkbox').removeAttr('checked');
      $("#toggle-arrow").removeClass("fa-chevron-up");
      $("#toggle-arrow").addClass("fa-chevron-down");
    }
  });
});

$(".advanced_search_toggle span").ready(function(){
  if ($('.search_toggle .button span').text() == 'Tools') {
    $('.advanced_search_toggle span').hide();
    $('.advanced_search_body').hide();
  }
});

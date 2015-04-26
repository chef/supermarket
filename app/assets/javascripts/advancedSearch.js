$(function() {
  if($.cookie('advancedSearch') == 'on'){
    $(".advanced_search_body").show();
  }

  $(".advanced_search_toggle span").click(function() {
    if ($(".advanced_search_body").is(":hidden")) {
      $(".advanced_search_body").slideDown(300);
      $.cookie('advancedSearch' ,'on')
    } else {
      $(".advanced_search_body").slideUp(240);
      $.cookie('advancedSearch', 'off')
    }
  });
});

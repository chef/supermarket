$(function() {
  $('.search_toggle .f-dropdown a').click(function(e) {
    e.preventDefault();
    $('.search_form').attr('action', $(this).data('url'));
    $('.search_toggle .button span').text($(this).text());
    $('.search_form input[type=search]').focus();
    $('#search-types').foundation('dropdown', 'close', $('#search-types'));

    if($('.search_toggle .button span').text() == 'Tools'){
      $(".advanced_search_toggle span").hide();
      $(".advanced_search_body").hide();
      $.cookie('advancedSearch', 'off');
      $('input:checkbox').removeAttr('checked');
    }
    else{
      $('.advanced_search_toggle span').show();
    }
  });
});

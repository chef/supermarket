$(function() {
  $('input[type=checkbox].auto.trigger').on('change', function() {
    $(this).closest('form').submit();
  });
});


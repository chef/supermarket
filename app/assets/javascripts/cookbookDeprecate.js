$(document).on('opened', '[data-reveal]', function () {
  var settings =  {
    placeholder: 'Search for a cookbook',
    minimumInputLength: 3,
    width: '100%',
    ajax: {
      url: function () {
        return $(this).data('url');
      },
      dataType: 'json',
      quietMillis: 200,
      data: function (term, page) {
        return { q: term };
      },
      results: function (data, page) {
        return { results: data.items };
      },
    },
    id: function(object) {
      return object.cookbook_name;
    },
    formatSelection: function(object, container) {
      return object.cookbook_name;
    },
    formatResult: function(object, container) {
      return object.cookbook_name;
    }
  }

  $('.cookbook-deprecate').select2(settings);

  $('.cookbook-deprecate').on("select2-selecting", function(e) {
    $('.submit-deprecation').prop('disabled', false);
  });
});

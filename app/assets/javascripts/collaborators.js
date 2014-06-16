$(document).on('opened', '[data-reveal]', function () {
  var settings =  {
    placeholder: 'Search for a collaborator',
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
        return {results: data.collaborators};
      }
    },
    formatSelection: function(collaborator, container) {
      return collaborator.username;
    },
    formatResult: function(collaborator, container) {
      return collaborator.first_name + ' ' + collaborator.last_name + ' (' + collaborator.username + ')';
    }
  }

  $('.collaborators').select2(settings);
  $('.collaborators.multiple').select2($.extend(settings, {multiple: true}));
});

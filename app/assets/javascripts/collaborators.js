$(document).on('opened', '[data-reveal]', function () {
  $('#cookbook_collaborator_user_id').select2({
    placeholder: 'Search for a collaborator',
    minimumInputLength: 3,
    multiple: true,
    width: '100%',
    ajax: {
      url: function () {
        return $('#new_cookbook_collaborator').attr('action');
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
  });
});

$(function() {
  $('#cookbook_collaborator_user_id').select2({
    placeholder: 'Search for a collaborator',
    minimumInputLength: 3,
    multiple: true,
    width: '400px',
    ajax: {
      url: '/collaborators.json',
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
      return collaborator.first_name + ' ' + collaborator.last_name + '(' + collaborator.username + ')';
    }
  });
});

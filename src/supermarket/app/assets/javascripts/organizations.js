$(function () {
  var settings =  {
    placeholder: 'Search for an organization',
    minimumInputLength: 3,
    width: '100%',
    ajax: {
      url: function () {
        return $(this).data('url');
      },
      dataType: 'json',
      quietMillis: 200,
      data: function (term, page) {
        return {q: term};
      },
      results: function (data, page) {
        return {results: data};
      }
    },
    formatSelection: function(obj, container) {
      return obj.company + ', signed on ' + obj.signed_at;
    },
    formatResult: function(obj, container, query) {
      return obj.company + ', signed on ' + obj.signed_at;
    },
    id: function(obj) {
      return obj.organization_id
    }
  }

});

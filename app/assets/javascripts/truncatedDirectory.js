$(function() {
  $('.truncated_directory').each(function(i, directory) {
    var $directory = $(directory);
    var initialSize = Number(directory.dataset.initialSize || 5);

    var truncated = $directory.find('[data-index]').filter(function() {
      return Number(this.dataset.index || 0) >= initialSize;
    });

    if(truncated.size() > 0) {
      var expandButton = $directory.find('.expand');
      var collapseButton = $directory.find('.collapse');

      expandButton.on('click', function(e) {
        e.preventDefault();

        truncated.show();

        expandButton.hide();
        collapseButton.show();
      });

      collapseButton.on('click', function(e) {
        e.preventDefault();

        truncated.hide();

        expandButton.show();
        collapseButton.hide();
      });

      truncated.hide();
      expandButton.show();
    }
  });
});

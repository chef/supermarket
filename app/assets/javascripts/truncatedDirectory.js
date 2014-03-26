var TruncatedDirectory = function($directory, initialSize) {
  var expandClassName = 'expand';
  var collapseClassName = 'collapse';

  var truncated = $directory.find('li').filter(function(index) {
    var classNames = this.className.split(' ');
    var notExpandButton = classNames.indexOf(expandClassName) === -1;
    var notCollapseButton = classNames.indexOf(collapseClassName) === -1;

    if(notExpandButton && notExpandButton) {
      return index >= initialSize;
    }
  });

  if(truncated.size() > 0) {
    var expandButton = $directory.find('.' + expandClassName);
    var collapseButton = $directory.find('.' + collapseClassName);

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
}

$(function() {
  $('.truncated_directory').each(function(i, directory) {
    new TruncatedDirectory($(directory), 5);
  });
});

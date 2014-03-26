describe('Truncated Directories', function() {
  var directory = '\
    <ul id="directory">\
      <li class="item">One</li>\
      <li class="item">Two</li>\
      <li class="expand"><a href="#">View All</a></li>\
      <li class="collapse"><a href="#">View All</a></li>\
    </ul>\
  ';

  it('initially displays only the specified number of items', function() {
    $(document.body).append(directory);

    new TruncatedDirectory($('#directory'), 1);

    expect($('#directory').find('.item:visible').size()).to.equal(1)
  });

  it('shows the full list when the .expand button is clicked', function() {
    $(document.body).append(directory);

    new TruncatedDirectory($('#directory'), 1);

    $('#directory .expand').click();

    expect($('#directory').find('.item:visible').size()).to.equal(2)
  });

  it('shows the initial list when the .collapse button is clicked', function() {
    $(document.body).append(directory);

    new TruncatedDirectory($('#directory'), 1);

    $('#directory .expand').click();
    $('#directory .collapse').click();

    expect($('#directory').find('.item:visible').size()).to.equal(1)
  });
});

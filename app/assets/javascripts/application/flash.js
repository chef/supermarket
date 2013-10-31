// Script for handling flash messages

// Add a dismissed class to the flash when the close button is clicked.
$('div.flash a.close').on('click', function(e) {
  e.preventDefault();
  $(e.currentTarget).parents('div.flash').addClass('dismissed');
});

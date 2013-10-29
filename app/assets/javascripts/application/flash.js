// Script for handling flash messages

// Add a dismissed class to the flash when the close button is clicked.
$(document.body).on('click', '.flash .close', function (event) {
    event.preventDefault()
    $(event.currentTarget).parents('.flash').addClass('dismissed');
});

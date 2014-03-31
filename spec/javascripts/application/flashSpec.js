describe('Flash module', function () {
    it('disappears when the close button is clicked', function (done) {
        var flash = $('<div data-alert class="flash"><a href="#" class="close">x</a></div>');
        $(document.body).append(flash);
        $(document).foundation();
        $('.flash .close').click();

        setTimeout(function() {
          expect($('.flash:visible').size()).to.equal(0);
          done();
        }, 500);
    });
});

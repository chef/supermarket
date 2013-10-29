describe('Flash module', function () {
    it('has a .dismissed class applied when the close button is clicked', function () {
        var flash = $('<div class="flash"><a href="#" class="close">x</a></div>');
        $(document.body).append(flash);
        $('.flash .close').click();
        expect(flash.hasClass('dismissed')).to.be.true
    });
});

/*
* http://github.com/amiel/html5support
* Amiel Martin
* 2010-01-26
*
* Support certain HTML 5 attributes with javascript, but only if the browser doesn't already support them.
*/

var HTML5Support = (function($){
    var // private members
        // if no value is specified, find placeholder text in this html attribute
        placeholder_attribute = 'placeholder',
        // give the input field this class when the placeholder text is used
        placeholder_klass = placeholder_attribute,
        // this will become our HTML5Support object
        h5 = {};

    // public functions
    $.extend(h5, {
        supports_attribute: function(attribute, type) { // should we memoize this?
            return attribute in document.createElement(type || 'input');
        }
    });

    // private functions
    function tabularosa() {
        var self = $(this),
            // I've added three unprintable invisible characters to the end here.
            // That indicates without a doubt that the value in the box was put
            // there as a placeholder and not by the user.  This is great for
            // situations when the placeholder might be "USA" and the user enters
            // the string "USA", and it disappears and gets a placeholder class.
            // I tried fixing it the right way, but that didn't seem to work across
            // refreshes in firefox.
            value = self.attr(placeholder_attribute) + "\u00A0\u00A0\u00A0",
        set_value = function() {
            if ($.trim(self.val()) == '' || self.val() == value)
            self.val(value).addClass(placeholder_klass);
        },
        clear_value = function() {
            if (self.val() == value) {
                self.val('');
            }
            self.removeClass(placeholder_klass);
        };
        self.focus(clear_value).blur(set_value).blur();
    }

    // this one is sort of hacky
    function password_tabularosa() {
        var self = $(this),
            value = self.attr(placeholder_attribute),
            placeholder_input = $('<input type="text">').val(value).
                addClass(placeholder_klass).addClass(self.attr('class')).
                css('display', 'none');

        set_value = function() {
            if ($.trim(self.val()) == '') {
                placeholder_input.show();
                self.hide();
            }
        },
        clear_value = function() {
            placeholder_input.hide();
            self.show().focus();
        };
        self.after(placeholder_input);
        placeholder_input.focus(clear_value);
        self.blur(set_value).blur();
    }


    // jquery plugins

    $.fn.placeholder = function(value) {
        if (h5.supports_attribute('placeholder')) return this;
        return this.each(function() {
            ($(this).attr('type') == 'password') ? password_tabularosa.apply(this) : tabularosa.apply(this);
        });
    };

    $.fn.autofocus = function() {
        if (h5.supports_attribute('autofocus')) return this;
        return this.focus();
    };


    $.autofocus = function() { $('[autofocus]:visible').autofocus(); };
    $.placeholder = function() { $('['+placeholder_attribute+']').placeholder(); };

    $.html5support = function() { $.autofocus(); $.placeholder(); };

    return h5;
})(jQuery);

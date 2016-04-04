# Branding

This directory is intended to hold one or more optional .scss files
that override the default branding variables declared in
`../default_branding.scss` or `../variables.scss`.  Files in this
directory are included into common.scss via the sass-globbing gem.

Notes:

* Other than this README and the `dummy_do_not_edit.scss`, this
directory is not tracked in git.

* `dummy_do_not_edit.scss` exists solely to prevent sass-globbing from
throwing an error.  Do not edit it.

* Branding images should be added under `app/assets/images/branding`,
  and the image paths should include the `branding` directory; e.g.,
  `$appheader_logo_svg: 'branding/colored-logo.svg';`.

## Demo

To see a simple demo of branding, in this directory, create
`mybranding.scss` in this directory with the following content, and
add an svg image at `app/assets/images/branding/colored-logo.svg`:

    $search_input_bg_color: #ff0000;
    $appheader_logo_svg: 'branding/colored-logo.svg';

and reload your development supermarket.

Note it's also possible to do things like redefine constants
(eg, `$secondary_blue: #ff0000;`).

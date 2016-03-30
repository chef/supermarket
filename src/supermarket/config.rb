# Require any additional compass plugins here.
require 'sass-globbing'

# Set this to the root of your project when deployed:
http_path = '/'
css_dir = 'app/assets/stylesheets'
sass_dir = 'app/assets/stylesheets'
images_dir = 'app/assets/images'
javascripts_dir = 'app/assets/javascripts'

# You can select your preferred output style here (can be overridden via the command line):
output_style = :compressed

# To enable relative paths to assets via compass helper functions. Uncomment:
# relative_assets = true

preferred_syntax = :scss

# Remove SASS/Compass relative comments.
line_comments = false

# SASS core
# -----------------------------------------------------------------------------

# Chrome needs a precision of 7 to round properly
Sass::Script::Number.precision = 7

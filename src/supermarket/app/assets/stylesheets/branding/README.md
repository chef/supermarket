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

## Production

Changing branding and making the change active in production is a little tricky.

Images and CSS (or SCSS) must currently be placed here, deep within the web application's directory structure. Customing the look requires comfort with CSS, SCSS, and Supermarket's current document structure and styles.

Below is an example of how you might customize the header logo of a private Supermarket, the simplest and most-requested branding customization. This can be done in a wrapper cookbook that already installs a Supermarket. It demonstrates how to retrieve an image file over the network and declare that this image should be used in the header. (And, for fun, also turns the search entry field red. Red is not recommended for production. Red upsets people.)

```ruby
# an appropriate place to store some custom branding
branding_config_dir = '/etc/supermarket/branding'
directory branding_config_dir

# within this appropriate place, spots for custom images and CSS styles
['images', 'stylesheets'].each do |asset_type|
  directory "#{branding_config_dir}/#{asset_type}"

  # link the deeply embedded branding asset directories to the real, more appropriate places
  # trigger an asset recompile if these links are recreated because that'll happen after an
  # upgrade
  link "/opt/supermarket/embedded/service/supermarket/app/assets/#{asset_type}/branding" do
    to "#{branding_config_dir}/#{asset_type}"
    notifies :run, 'execute[recompile assets]'
  end
end

# -- BEGIN actual customization --
# resources in here represent the actual branding changes to be made

# resource should use "notifies :run, 'execute[recompile assets]'" to
# trigger web app asset recompilation only on Chef runs where the branding
# has actually changed

# an example of grabbing an appropriate logo from somewhere
remote_file "#{branding_config_dir}/images/customlogo.jpg" do
  source 'https://example.com/some/customlogo.jpg'
  notifies :run, 'execute[recompile assets]'
end

# writing custom SCSS to use the logo above and to change the search form background color
file "#{branding_config_dir}/stylesheets/custombranding.scss" do
  content <<~CUSTOM_SCSS
    $appheader_logo_svg: 'branding/customlogo.jpg';
    $search_input_bg_color: #ff0000;
  CUSTOM_SCSS
  notifies :run, 'execute[recompile assets]'
end
# -- END actual customization

# recompiles the web app's CSS, JavaScript, and image assets only when notified
# that something changed
execute 'recompile assets' do
  command 'cd /opt/supermarket/embedded/service/supermarket && \
           RAILS_ENV="production" env PATH=/opt/supermarket/embedded/bin \
           bin/rake assets:precompile'
  action :nothing
end

# restart the web app if branding assets have changed to make the changes active
execute 'supermarket-ctl restart rails' do
  action :nothing
  subscribes :run, 'execute[recompile assets]'
end
```

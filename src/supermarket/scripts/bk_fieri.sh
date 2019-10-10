#!/bin/bash

# Install the required packages
apt-get update -y && apt-get install -y gcc make libpq-dev libxslt1-dev libxml2-dev libmagic-dev libsqlite3-dev curl git  libreadline-dev

# Install ASDF software manager
echo "--- Installing ASDF software version manager from master"
git clone https://github.com/asdf-vm/asdf.git /opt/asdf

bash /opt/asdf/asdf.sh
bash /opt/asdf/completions/asdf.bash

echo "--- Installing Ruby ASDF plugin"
/opt/asdf/bin/asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git

echo "--- Installing Ruby 2.5.6"
/opt/asdf/bin/asdf install ruby 2.5.6
/opt/asdf/bin/asdf global ruby 2.5.6

export PATH=/root/.asdf/installs/ruby/2.5.6/bin:/opt/asdf/installs/ruby/2.5.6/bin:~/.asdf/shims:/opt/asdf/bin:/opt/asdf/shims:$PATH

which ruby
ruby --version
which bundle

gem install bundler -v 1.17.3 --no-document

redis-server &

export CHEF_LICENSE="accept-silent"

echo "--- bundle install"
bundle install --without development --jobs 7 --retry=3 --path=vendor/bundle

echo "--- bundle exec rake spec"
bundle exec rake spec

echo "--- bundle exec rubocop"
bundle exec rubocop

echo "--- bundle exec bundle-audit check"
bundle exec bundle-audit check --update
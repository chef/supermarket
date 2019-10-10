#!/bin/bash

# Install required packages
apt-get update -y && apt-get install -y libpq-dev libxslt1-dev libxml2-dev libmagic-dev libsqlite3-dev curl make libreadline-dev

# Install PhantomJS 2.1.1 from a downloaded package because Ubuntu package is broken
cd /tmp
wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2
bzip2 -d phantomjs-2.1.1-linux-x86_64.tar.bz2
tar -xvf phantomjs-2.1.1-linux-x86_64.tar
cp phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/bin/phantomjs

export PATH=/root/.asdf/installs/ruby/2.5.6/bin:/opt/asdf/installs/ruby/2.5.6/bin:~/.asdf/shims:/opt/asdf/bin:/opt/asdf/shims:$PATH

which ruby
ruby --version
which bundle

gem install bundler -v 1.17.3 --no-document
export CHEF_LICENSE="accept-silent"

# Configure and restart postgres
cp /workdir/src/supermarket/scripts/pb_hba.conf /etc/postgresql/9.3/main/pg_hba.conf
service postgresql restart

# Start redis service
redis-server &

cd /workdir/src/supermarket

echo "--- Create supermarket test and development databases"
psql -c 'create database supermarket_test;' -U postgres
psql -c 'create database supermarket_development;' -U postgres

echo "--- bundle config"
bundle config build.nokogiri --use-system-libraries

echo "--- bundle install"
bundle install --without development --jobs 7 --path vendor/bundle

echo "--- bundle exec rake db:schema:load"
bundle exec rake db:schema:load

echo "--- bundle exec rake spec"
bundle exec rake spec

echo "--- bundle exec rubocop"
bundle exec rubocop

echo "--- bundle exec bundle-audit"
bundle exec bundle-audit check --update --ignore CVE-2015-9284
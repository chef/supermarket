#
# Cookbook Name:: build_cookbook
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

#########################################################################
# Docker
#########################################################################
include_recipe 'chef-apt-docker::default'

package "docker-engine"

execute 'install docker-compose' do
  command <<-EOH
curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
EOH
end

# Ensure the `dbuild` user is part of the `docker` group so they can
# connect to the Docker daemon
execute "usermod -aG docker #{node['delivery_builder']['build_user']}"

#########################################################################
# Install a relatively up-to-date version of PhantomJS for app specs
#########################################################################

remote_file 'Retrieve a pre-built PhantomJS' do
  source 'http://cnpmjs.org/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2'
  path "#{node['delivery']['workspace']['cache']}/phantomjs-2.1.1-linux-x86_64.tar.bz2"
end

execute 'Place PhantomJS in path' do
  command <<-CMD
tar xjvf phantomjs-2.1.1-linux-x86_64.tar.bz2 phantomjs-2.1.1-linux-x86_64/bin/phantomjs && \
mv phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin && \
chmod +x /usr/local/bin/phantomjs
CMD
  cwd node['delivery']['workspace']['cache']
end


#########################################################################
# Install Ruby and dependency packages
#########################################################################

ruby_install node['build_cookbook']['ruby_version']

%w(
  libpq-dev
  libsqlite3-dev
  nodejs
).each do |dependency|
  package dependency
end

# get to the project root and use it as a cache
# as it is persistent between build jobs
gem_cache = File.join(node['delivery']['workspace']['root'], "../../../project_gem_cache")

directory gem_cache do
  # set the owner to the dbuild so that the other recipes can write to here
  owner node['delivery_builder']['build_user']
  mode '0755'
  recursive true
  action :create
end

#
# Cookbook Name:: build_cookbook
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

if node['delivery']['change']['phase'] == "unit"
  include_recipe 'build_cookbook::_install_docker'
  include_recipe 'build_cookbook::_install_phantomjs'
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

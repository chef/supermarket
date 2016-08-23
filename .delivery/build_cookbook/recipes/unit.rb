#
# Cookbook Name:: build_cookbook
# Recipe:: unit
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

gem_cache = File.join(node['delivery']['workspace']['root'], "../../../project_gem_cache")

node['build_cookbook']['components'].each do |component|
  ruby_execute "Tests for #{component}" do
    version node['build_cookbook']['ruby_version']
    command 'bundle install && bundle exec rspec'
    cwd "#{delivery_workspace_repo}/src/#{component}"
    environment('BUNDLE_PATH' => gem_cache)
  end
end

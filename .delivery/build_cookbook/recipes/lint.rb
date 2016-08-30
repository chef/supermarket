#
# Cookbook Name:: build_cookbook
# Recipe:: lint
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

gem_cache = File.join(node['delivery']['workspace']['root'], "../../../project_gem_cache")

ruby_execute "Rubocop linting" do
  version node['build_cookbook']['ruby_version']
  command <<-CMD
bundle install && \
bundle exec rubocop --display-cop-names --display-style-guide --format simple --format worst
CMD
  cwd "#{delivery_workspace_repo}/src/supermarket"
  environment('BUNDLE_PATH' => gem_cache)
end

#
# Cookbook Name:: build_cookbook
# Recipe:: unit
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

#########################################################################
# Call me Ishmael, whale killer
#
# A handler created to stop and remove containers started with docker-compose
# at the end of this phase. The containers are where services are running
# on which the tests depend (e.g. PostgreSQL, Redis)
#########################################################################

class DockerComposeKiller < Chef::Handler
  attr_accessor :cwd

  def initialize(cwd)
    @cwd = cwd
  end

  def report
    Chef::Log.info("Tearing down docker-composed dependency services.")
    cmd = "docker-compose down"
    so = Mixlib::ShellOut.new(cmd, cwd: cwd)
    so.run_command
    if so.error?
      Chef::Log.error("ROLLBACK FAILED")
      Chef::Log.error(so.stdout)
    end
  end
end

ishmael = DockerComposeKiller.new("#{delivery_workspace_repo}/src/supermarket")
Chef::Config.exception_handlers << ishmael
Chef::Config.report_handlers << ishmael

execute 'Startup dependency services in Docker' do
  command 'docker-compose up -d'
  cwd "#{delivery_workspace_repo}/src/supermarket"
  environment('USER' => node['delivery_builder']['build_user'])
  live_stream true
end

gem_cache = File.join(node['delivery']['workspace']['root'], "../../../project_gem_cache")

ruby_execute "Tests for Supermarket" do
  version node['build_cookbook']['ruby_version']
  command <<-CMD
bundle install && \
bundle exec rake db:create db:schema:load db:test:prepare && \
bundle exec rspec --color --format documentation
CMD
  cwd "#{delivery_workspace_repo}/src/supermarket"
  environment('BUNDLE_PATH' => gem_cache)
end

ruby_execute "Tests for Fieri" do
  version node['build_cookbook']['ruby_version']
  command <<-CMD
bundle install && \
bundle exec rspec --color --format documentation
CMD
  cwd "#{delivery_workspace_repo}/src/fieri"
  environment('BUNDLE_PATH' => gem_cache)
end

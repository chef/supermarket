#
# Cookbook Name:: build_cookbook
# Recipe:: provision
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Create an Application Release object in Chef Automate
expeditor_workflow_release workflow_change_project do
  action :create
  not_if { skip_omnibus_build? }
  only_if { workflow_stage?('acceptance') }
end

# Let delivery-truck do the workflow release promotion
include_recipe 'delivery-truck::provision'

# Promote the omnibus artifact to current
expeditor_artifactory workflow_change_project do
  ref_type 'omnibus.version'
  ref lazy { get_workflow_application_release(workflow_change_project)['version'] }
  channel 'current'
  action :promote
  only_if { workflow_stage?('union') }
end

# Stand up the Supermarket instance
execute 'apply-terraform' do
  command 'make apply'
  cwd supermarket_repo_terraform_directory
  environment supermarket_terraform_environment_vars
  live_stream true
end

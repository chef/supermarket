#
# Cookbook Name:: build_cookbook
# Recipe:: publish
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Create Acceptance environment (if missing) so we can pin the cookbooks
chef_environment workflow_project_acceptance_environment do
  chef_server automate_chef_server_details
  action :create
end

include_recipe 'delivery-truck::publish'

# Bump the version and add a tag to Github
expeditor_version workflow_change_project do
  action :bump
  not_if { artifact_exists_for_change? || skip_omnibus_build? }
end

# Trigger a jenkins build
expeditor_jenkins_job "#{workflow_change_project}-build" do # ~FC005
  git_ref workflow_change_merge_sha
  initiated_by workflow_project_slug
  action :trigger_async
  not_if { artifact_exists_for_change? || skip_omnibus_build? }
end

# If there are every additional activities that you want to do while your
# omnibus build is happening (i.e. build habitat packages), you can do them
# here between the async trigger and the wait_for_complete.

# Wait for the jenkins build to finish
expeditor_jenkins_job "#{workflow_change_project}-build" do
  git_ref workflow_change_merge_sha
  initiated_by workflow_project_slug
  action :wait_until_complete
  not_if { artifact_exists_for_change? || skip_omnibus_build? }
end

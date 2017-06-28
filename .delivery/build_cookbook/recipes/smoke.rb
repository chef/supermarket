#
# Cookbook Name:: build_cookbook
# Recipe:: smoke
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Trigger the Jenkins smoke tests
expeditor_jenkins_job "#{workflow_change_project}-test" do # ~FC005
  git_ref workflow_change_merge_sha
  initiated_by workflow_project_slug
  action :trigger_async
  not_if { skip_omnibus_build? }
  only_if { workflow_stage?('acceptance') }
end

# If there are every additional activities that you want to do while your
# omnibus test is happening (i.e. run inspec tests), you can do them
# here between the async trigger and the wait_for_complete.

# Wait for the Jenkins smoke tests to complete
expeditor_jenkins_job "#{workflow_change_project}-test" do
  git_ref workflow_change_merge_sha
  initiated_by workflow_project_slug
  action :wait_until_complete
  not_if { skip_omnibus_build? }
  only_if { workflow_stage?('acceptance') }
end

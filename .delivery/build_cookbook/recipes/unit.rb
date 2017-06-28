#
# Cookbook Name:: build_cookbook
# Recipe:: unit
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

secrets = get_project_secrets

# Wait for the Github PR status to be green
github_pull_request_status "chef/#{workflow_change_project}" do
  api_token secrets['github']['chef-delivery']
  git_ref workflow_stage?('verify') ? workflow_change_github_branch : workflow_change_merge_sha
  action :wait_for_success_or_failure
end

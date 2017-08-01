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

#########################################################################
# Inspec Smoke Tests
#########################################################################

# Get a list of all the nodes that we need to test against
infra_nodes = infra_nodes_for(workflow_change_project, workflow_change_pipeline, workflow_stage)

supermarket_nodes = infra_nodes.find_all { |infra_node| infra_node['chef_product_key'] == 'supermarket' }
supermarket_fqdns = supermarket_nodes.map(&:name)

# We will run all our inspec commands in parallel, so add the profiles you want
# to execute to this array.
inspec_commands = []

# Tests to run against Supermarket instances in every environment
supermarket_smoke_tests = %w(
  supermarket-smoke
)
inspec_commands << inspec_commands_for(supermarket_smoke_tests, supermarket_fqdns, sudo: true)

# Execute all the tests in parallel (for speed!)
parallel_execute "Execute inspec smoke tests against #{workflow_stage}" do
  commands inspec_commands.flatten.uniq
  cwd workflow_workspace_repo
  environment(
    'PATH' => chefdk_path,
    'HOME' => workflow_workspace
  )
end

# Wait for the Jenkins smoke tests to complete
expeditor_jenkins_job "#{workflow_change_project}-test" do
  git_ref workflow_change_merge_sha
  initiated_by workflow_project_slug
  action :wait_until_complete
  not_if { skip_omnibus_build? }
  only_if { workflow_stage?('acceptance') }
end

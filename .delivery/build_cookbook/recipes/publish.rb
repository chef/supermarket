#
# Cookbook Name:: build_cookbook
# Recipe:: publish
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

#########################################################################
# TODO: set these things in `delivery-bus`
#########################################################################
delivery_bus_secrets = DeliverySugar::ChefServer.new.encrypted_data_bag_item('delivery-bus', 'secrets')

node.set['jenkins']['master']['endpoint']  = 'http://wilson.ci.chef.co'
node.set['jenkins']['executor']['timeout'] = 7200 # wait up to 2 hours for jobs to complete
node.run_state[:jenkins_private_key]       = delivery_bus_secrets['jenkins_private_key']

#########################################################################
# BUMP AND PUBLISH TAGS
#
# TODO: We need to create a resource/primitive that handles all the tag
#       bumping and pushing as we have exceeded the Rule of Three. That
#       is to say this is the fourth project we have done this logic in
#       (first three were Delivery, Compliance and Chef Backend).
#
#########################################################################

git_ssh = File.join(delivery_workspace, 'bin', 'git_ssh')

execute 'Set a user and email for git operations' do
  command <<-CMD
git config user.name "Delivery Builder - Supermarket Pipeline" && \
git config user.email "builder@delivery.chef.co"
CMD
  cwd delivery_workspace_repo
  environment({"GIT_SSH" => git_ssh})
end

execute 'Fetch latest tags from Workflow server' do
  command "git fetch --tags"
  cwd delivery_workspace_repo
  environment({"GIT_SSH" => git_ssh})
end

# Push changes up to the GitHub repo
delivery_github 'chef/supermarket' do
  tag lazy { VersionBumper.next_version(delivery_workspace_repo) }
  deploy_key delivery_bus_secrets['github_private_key']
  branch node['delivery']['change']['pipeline']
  remote_url "git@github.com:chef/supermarket.git"
  repo_path node['delivery']['workspace']['repo']
  cache_path node['delivery']['workspace']['cache']
  action :push
end

execute 'Push the new tag to Workflow server' do
  command 'git push origin --tags'
  cwd delivery_workspace_repo
  environment({ 'GIT_SSH' => git_ssh })
end



#########################################################################
# Execute the build in Jenkins. The `jenkins_job` resource will block
# until completion AND stream back log output into the current CCR.
#########################################################################
jenkins_job "supermarket-build" do
  parameters(
    'GIT_REF' => node['delivery']['change']['sha'], # TODO: expose the change SHA in delivery-sugar,
    'APPEND_TIMESTAMP' => 'false', # ensure we don't append a timestamp to our build version
    'DELIVERY_CHANGE' => delivery_change_id,
    'DELIVERY_SHA' => node['delivery']['change']['sha'],
  )
  action :build
end

#
# Cookbook Name:: build_cookbook
# Recipe:: deploy
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

infra_nodes = infra_nodes_for(workflow_change_project, workflow_change_pipeline, workflow_stage)
infra_node_names = infra_nodes.map(&:name)

# Set the run list on all nodes
infra_nodes.each do |infra_node|
  chef_node infra_node.name do
    chef_server automate_chef_server_details
    run_list %W(
      recipe[cd-infrastructure-base::default]
      recipe[supermarket-deploy::#{recipe_for(infra_node)}]
    )
  end
end

# Execute a CCR on the instances to bring up Supermarket
parallel_remote_execute "Run CCR on #{infra_node_names}" do
  command 'sudo /opt/chef/bin/chef-client'
  hosts infra_node_names
  private_key aws_private_key
  timeout 7200 # 2 hours
end

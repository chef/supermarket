require 'aws-sdk'
require 'json'
require 'open-uri'

module BuildCookbook
  module Helpers
    #########################################################################
    # Github
    #########################################################################
    def skip_omnibus_build?
      pr_has_label?(node['build-cookbook']['pr_labels']['omnibus_skip_build'])
    end

    #########################################################################
    # AWS
    #########################################################################
    def aws_profile
      node['build-cookbook']['aws_profile']
    end

    def aws_key_name
      node['build-cookbook']['aws_key_name']
    end

    def aws_private_key
      node['build-cookbook']['aws_private_key']
    end

    #########################################################################
    # Terraform
    #########################################################################
    def terraform_path
      es_terraform_path(node['build-cookbook']['terraform_version'])
    end

    # Directory for the terraform directory in the workspace_repo
    def supermarket_repo_terraform_directory
      File.join(workflow_workspace_repo, 'terraform')
    end

    # Construct the path to the correct TF_DIRECTORY
    def terraform_directory_for(stage)
      subdir = stage == 'acceptance' ? 'acceptance' : 'u-r-d'
      File.join(supermarket_repo_terraform_directory, subdir)
    end

    # Construct a hash that can be provided to a chef_managed_instance terraform module
    def supermarket_terraform_environment_vars(stage = workflow_stage, environment = workflow_environment)
      {
        'AWS_PROFILE' => aws_profile,
        'HOME' => workflow_workspace,
        'PATH' => terraform_path,
        'TF_ENVIRONMENT' => stage,
        'TF_DIRECTORY' => terraform_directory_for(stage),
        'TF_VAR_automate_project' => workflow_change_project,
        'TF_VAR_automate_pipeline' => workflow_change_pipeline,
        'TF_VAR_chef_environment' => environment,
        'TF_VAR_chef_server_url' => automate_chef_server_details[:chef_server_url],
        'TF_VAR_chef_user_name' => automate_chef_server_details[:options][:client_name],
        'TF_VAR_chef_user_key' => automate_chef_server_details[:options][:signing_key_filename],
        'TF_VAR_aws_key_name' => aws_key_name,
        'TF_VAR_aws_private_key' => aws_private_key,
      }
    end

    #########################################################################
    # Inspec
    #########################################################################
    # Coming soon!
  end
end

Chef::Node.send(:include, BuildCookbook::Helpers)
Chef::Recipe.send(:include, BuildCookbook::Helpers)
Chef::Resource.send(:include, BuildCookbook::Helpers)

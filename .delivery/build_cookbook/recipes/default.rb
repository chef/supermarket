#
# Cookbook Name:: build_cookbook
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

secrets = get_project_secrets

#########################################################################
# github.com SCM Integration
#########################################################################

es_github_service_user 'chef-delivery' do
  github_repo "chef/#{workflow_change_project}"
  action :configure
end

#########################################################################
# AWS CLI
#########################################################################

es_aws_cli aws_profile do
  key_name aws_key_name
  key_contents secrets['chef-cd-aws']['private_key']
  access_key_id secrets['chef-cd-aws']['access_key_id']
  secret_access_key secrets['chef-cd-aws']['secret_access_key']
  action :configure
end

#########################################################################
# Terraform
#########################################################################

es_terraform node['build-cookbook']['terraform_version'] do
  action :install
end

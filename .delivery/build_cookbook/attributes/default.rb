#
# Cookbook Name:: build-cookbook
# Attributes:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
#

#########################################################################
# Terraform
#########################################################################

default['build-cookbook']['terraform_version'] = '0.8.1'

#########################################################################
# AWS
#########################################################################

default['build-cookbook']['aws_profile']     = 'chef-cd'
default['build-cookbook']['aws_key_name']    = 'cd-infrastructure'
default['build-cookbook']['aws_private_key'] = File.join(node['delivery']['workspace_path'], '.ssh', "#{node['build-cookbook']['aws_key_name']}.pem")

#########################################################################
# Github
#########################################################################

# Do not create a new Omnibus version. This also tells the pipeline not to bump the version.
default['build-cookbook']['pr_labels']['omnibus_skip_build'] = 'Omnibus: Skip Build'

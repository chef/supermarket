#
# Cookbook:: supermarket-deploy
# Recipe:: default
#
# Copyright:: 2017, Chef Software Inc Engineering, All Rights Reserved.

node.default['citadel']['bucket'] = 'chef-cd-citadel'
node.default['citadel']['region'] = 'us-west-2'

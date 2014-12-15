#
# Cookbook Name:: supermarket
# Recipe:: app
#
# Copyright 2014 Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Common configuration for Rails & Sidekiq

include_recipe 'omnibus-supermarket::config'
include_recipe 'omnibus-supermarket::rails'
include_recipe 'omnibus-supermarket::sidekiq'

file "#{node['supermarket']['var_directory']}/etc/env" do
  content Supermarket::Config.environment_variables_from(node['supermarket'])
  owner node['supermarket']['user']
  group node['supermarket']['group']
  mode '0600'
  notifies :restart, 'runit_service[sidekiq]' if node['supermarket']['sidekiq']['enable']
  notifies :restart, 'runit_service[rails]' if node['supermarket']['rails']['enable']
end

link "#{node['supermarket']['app_directory']}/.env.production" do
  to "#{node['supermarket']['var_directory']}/etc/env"
end

# Cookbook data is uploaded to /opt/supermarket/embedded/service/supermarket/public/system
directory node['supermarket']['data_directory'] do
  owner node['supermarket']['user']
  group node['supermarket']['group']
  mode '0755'
  action :create
end

link "#{node['supermarket']['app_directory']}/public/system" do
  to node['supermarket']['data_directory']
end

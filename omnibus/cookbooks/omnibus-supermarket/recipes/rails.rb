#
# Cookbook Name:: supermarket
# Recipe:: rails
#
# Copyright 2014-2016 Chef Software, Inc.
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

include_recipe 'omnibus-supermarket::config'
include_recipe 'omnibus-supermarket::nginx'

[node['supermarket']['rails']['log_directory'],
 "#{node['supermarket']['var_directory']}/rails/run"].each do |dir|
  directory dir do
    owner node['supermarket']['user']
    group node['supermarket']['group']
    mode '0700'
    recursive true
  end
end

template "#{node['supermarket']['var_directory']}/etc/unicorn.rb" do
  source 'unicorn.rb.erb'
  cookbook 'unicorn'
  owner node['supermarket']['user']
  group node['supermarket']['group']
  mode '0600'
  variables(node['supermarket']['unicorn'].to_hash)
  notifies :restart, 'runit_service[rails]'
end

template "#{node['supermarket']['nginx']['directory']}/sites-enabled/rails" do
  source 'rails.nginx.conf.erb'
  owner node['supermarket']['user']
  group node['supermarket']['group']
  mode '0600'
  notifies :reload, 'runit_service[nginx]' if node['supermarket']['nginx']['enable']
end

if node['supermarket']['rails']['enable']
  component_runit_service 'rails' do
    package 'supermarket'
  end
else
  runit_service 'rails' do
    action :disable
  end
end

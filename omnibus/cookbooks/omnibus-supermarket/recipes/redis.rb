#
# Cookbook Name:: supermarket
# Recipe:: redis
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

include_recipe 'omnibus-supermarket::config'
include_recipe 'enterprise::runit'

# Create directories
["#{node['supermarket']['redis']['directory']}/etc",
 "#{node['supermarket']['redis']['directory']}/run",
 "#{node['supermarket']['var_directory']}/lib/redis",
 node['supermarket']['redis']['log_directory']].each do |dir|
  directory dir do
    owner node['supermarket']['user']
    group node['supermarket']['group']
    mode '0700'
    recursive true
  end
end

template "#{node['supermarket']['redis']['directory']}/etc/redis.conf" do
  source 'redis.conf.erb'
  owner node['supermarket']['user']
  group node['supermarket']['group']
  mode '0600'
  notifies :restart, 'runit_service[redis]' if node['supermarket']['redis']['enable']
end

# Redis gives you a warning if you don't do this
sysctl 'vm.overcommit_memory' do
  value 1
end

if node['supermarket']['redis']['enable']
  component_runit_service 'redis' do
    package 'supermarket'
  end
else
  runit_service 'redis' do
    action :disable
  end
end

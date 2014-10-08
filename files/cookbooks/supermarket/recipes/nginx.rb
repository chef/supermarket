#
# Cookbook Name:: supermarket
# Recipe:: nginx
#
# Copyright 2014 Chef Supermarket Team
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

[node['supermarket']['nginx']['log_directory'],
 "#{node['supermarket']['nginx']['directory']}/etc",
 "#{node['supermarket']['nginx']['directory']}/etc/nginx.d"].each do |dir|
  directory dir do
    owner node['supermarket']['user']
    group node['supermarket']['group']
    mode '0700'
    recursive true
  end
end

if node['supermarket']['nginx']['enable']
  component_runit_service 'nginx' do
    package 'supermarket'
  end
else
  runit_service 'nginx' do
    action :disable
  end
end

template "#{node['supermarket']['nginx']['directory']}/etc/nginx.conf" do
  source 'nginx.conf.erb'
  owner node['supermarket']['user']
  group node['supermarket']['group']
  mode '0600'
  notifies :hup, 'runit_service[nginx]' if node['supermarket']['nginx']['enable']
end

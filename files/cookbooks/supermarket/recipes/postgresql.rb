#
# Cookbook Name:: supermarket
# Recipe:: postgresql
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

include_recipe 'supermarket::config'
include_recipe 'enterprise::runit'

[node['supermarket']['postgresql']['data_directory'],
 node['supermarket']['postgresql']['log_directory']].each do |dir|
  directory dir do
    owner node['supermarket']['user']
    group node['supermarket']['group']
    mode '0700'
    recursive true
  end
end

if node['supermarket']['postgresql']['enable']
  component_runit_service 'postgresql' do
    package 'supermarket'
    control ['t']
  end
else
  runit_service 'postgresql' do
    action :disable
  end
end

#
# Cookbook Name:: supermarket-builder
# Recipe:: default
#
# Copyright 2018 Chef Software, Inc.
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

# Used to build a package in the Test Kitchen build lab

# ensure packages available up-to-date
case node['platform_family']
when 'debian'
  apt_update
when 'rhel'
  include_recipe 'yum-epel::default'
end

include_recipe 'omnibus::default'

execute 'fix bundler directory permissions' do
  command "chown -R #{node['omnibus']['build_user']} #{node['omnibus']['build_user_home']}/.bundle"
end

# do the build
omnibus_build 'supermarket' do
  environment 'HOME' => node['omnibus']['build_user_home']
  project_dir node['omnibus']['build_dir']
  log_level :internal
  live_stream true
  config_overrides(
    append_timestamp: true
  )
end

#
# Cookbook Name:: supermarket
# Recipe:: build_package
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

# Used to build a package in the Test Kitchen build lab

include_recipe 'omnibus'

# The default resolver from vagrant seems to be flaky. Use Google's
file '/etc/resolv.conf' do
  content "nameserver 8.8.8.8\nnameserver 8.8.4.4"
  owner 'root'
  group 'root'
  mode '0644'
end

execute 'bundle install' do
  command 'bundle install --binstubs --without development'
  cwd node['omnibus']['build_dir']
  user node['omnibus']['build_user']
end

execute 'build package' do
  command "bin/omnibus build supermarket --log-level #{node['omnibus']['log_level']}"
  cwd node['omnibus']['build_dir']
  user node['omnibus']['build_user']
end

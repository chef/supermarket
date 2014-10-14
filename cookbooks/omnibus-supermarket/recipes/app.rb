#
# Cookbook Name:: supermarket
# Recipe:: app
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

# Common configuration for Rails & Sidekiq

include_recipe 'omnibus-supermarket::config'

file "#{node['supermarket']['var_directory']}/etc/env" do
  content Supermarket::Config.environment_variables_from(node['supermarket'])
  owner 'supermarket'
  group 'supermarket'
  mode '0600'
end

link "#{node['supermarket']['app_directory']}/.env.production" do
  to "#{node['supermarket']['var_directory']}/etc/env"
end

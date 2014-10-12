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

include_recipe 'supermarket::config'

file "#{node['supermarket']['var_directory']}/etc/database.yml" do
  content({
    'production' => {
      'adapter' => 'postgresql',
      'database' => node['supermarket']['database']['name'],
      'username' => node['supermarket']['database']['user'],
      'password' => node['supermarket']['database']['password'],
      'host' => node['supermarket']['database']['host'],
      'port' => node['supermarket']['database']['port'],
    }
  }.to_yaml)
  owner node['supermarket']['user']
  group node['supermarket']['group']
  mode '0600'
end

link "#{node['supermarket']['install_directory']}/embedded/service/supermarket/config/database.yml" do
  to "#{node['supermarket']['var_directory']}/etc/database.yml"
end

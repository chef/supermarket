#
# Cookbook Name:: supermarket
# Recipe:: database
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

# The enterprise_pg resources use the CLI to create databases and users. Set
# these environment variables so the commands have the correct connection
# settings.

ENV['PGHOST'] = node['supermarket']['database']['host']
ENV['PGPORT'] = node['supermarket']['database']['port'].to_s

enterprise_pg_user node['supermarket']['database']['user'] do
  superuser true
  password node['supermarket']['database']['password'] || ''
  # If the database user is the same as the main postgres user, don't create it.
  not_if do
    node['supermarket']['database']['user'] ==
      node['supermarket']['postgresql']['username']
  end
end

enterprise_pg_database node['supermarket']['database']['name'] do
  owner node['supermarket']['database']['user']
end

node['supermarket']['database']['extensions'].each do |ext, enable|
  execute "create postgresql #{ext} extension" do
    user node['supermarket']['database']['user']
    command "echo 'CREATE EXTENSION IF NOT EXISTS #{ext}' | psql"
    not_if "echo '\\dx' | psql #{node['supermarket']['database']['name']} | grep #{ext}"
  end
end

file "#{node['supermarket']['var_directory']}/etc/database.yml" do
  content({
    'production' => {
      'adapter' => 'postgresql',
      'database' => node['supermarket']['database']['name'],
      'username' => node['supermarket']['database']['user'],
      'password' => node['supermarket']['database']['password'],
      'host' => node['supermarket']['database']['host'],
      'port' => node['supermarket']['database']['port'],
      'pool' => node['supermarket']['database']['pool'],
    },
  }.to_yaml)
  owner node['supermarket']['user']
  group node['supermarket']['group']
  mode '0600'
end

link "#{node['supermarket']['app_directory']}/config/database.yml" do
  to "#{node['supermarket']['var_directory']}/etc/database.yml"
end

# Ensure the db schema is owned by the supermarket user, so dumping the db
# schema after migrate works
file "#{node['supermarket']['app_directory']}/db/schema.rb" do
  owner node['supermarket']['user']
end

execute 'database schema' do
  command 'bundle exec rake db:migrate db:seed'
  cwd node['supermarket']['app_directory']
  env 'RAILS_ENV' => 'production'
  user node['supermarket']['user']
end

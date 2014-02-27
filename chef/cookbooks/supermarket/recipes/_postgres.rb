#
# Author:: Seth Vargo (<sethvargo@gmail.com>)
# Recipe:: postgres
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

include_recipe 'supermarket::_apt'

package 'postgresql'
package 'postgresql-contrib'
package 'libpq-dev'

execute 'postgres[user]' do
  user 'postgres'
  command "echo 'CREATE ROLE #{node['postgres']['user']} WITH LOGIN CREATEDB;' | psql"
  not_if  "echo 'SELECT 1 FROM pg_roles WHERE rolname = \'#{node['postgres']['user']}\';' | psql | grep -q 1"
end

execute 'postgres[database]' do
  user 'postgres'
  command "echo 'CREATE DATABASE #{node['postgres']['database']};' | psql"
  not_if  "echo 'SELECT 1 FROM pg_database WHERE datname = \'#{node['postgres']['database']}\';' | psql | grep -q 1"
end

template '/etc/postgresql/9.1/main/pg_hba.conf' do
  notifies :restart, 'service[postgresql]', :immediately
end

service 'postgresql' do
  action [:enable, :start]
end

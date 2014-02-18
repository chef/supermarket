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
  command %Q(psql postgres -tAc "CREATE USER #{node['postgres']['user']}
    WITH PASSWORD '#{node['postgres']['password']}' CREATEDB CREATEUSER")

  # do not create user if the user already exists or authentication fails
  not_if %Q(su - postgres -c 'psql postgres -U postgres --no-password -tAc "SELECT 1 FROM pg_roles
    WHERE rolname='\\''#{node['postgres']['user']}'\\''" 2>&1 | grep -E -i -w -q "1|fe_sendauth"')
end

execute 'postgres[database]' do
  user 'postgres'
  command %Q(psql postgres -tAc "CREATE DATABASE #{node['postgres']['database']}")

  # do not create database if the database already exists or authentication fails
  not_if %Q(su - postgres -c 'psql postgres -U postgres --no-password -tAc "SELECT 1
    FROM pg_database WHERE datname='\\''#{node['postgres']['database']}'\\''" 2>&1 | grep -E -i -w -q "1|fe_sendauth"')
end

template '/etc/postgresql/9.1/main/pg_hba.conf' do
  notifies :restart, 'service[postgresql]', :immediately
end

service 'postgresql' do
  action [:enable, :start]
end

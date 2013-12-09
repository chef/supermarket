#
# Author:: Seth Vargo (<sethvargo@gmail.com>)
# Recipe:: postgres
#
# Copyright 2013 Chef, Inc.
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

execute 'postgres_user[vagrant]' do
  user 'postgres'
  command 'createuser vagrant --superuser'
  not_if %q(su - postgres -c 'psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='\''vagrant'\''" | grep -q 1')
end

template '/etc/postgresql/9.1/main/pg_hba.conf' do
  notifies :restart, 'service[postgresql]', :immediately
end

service 'postgresql' do
  action :nothing
end

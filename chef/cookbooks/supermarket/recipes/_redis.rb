#
# Author:: Brian Cobb (<brian@cramerdev.com>)
# Author:: Brett Chalupa (<brett@cramerdev.com>)
# Recipe:: redis
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

# Redis is required for Sidekiq

include_recipe 'supermarket::_apt'

execute 'add-apt-repository[ppa:chris-lea]' do
  command 'add-apt-repository -y ppa:chris-lea/redis-server'
  notifies :run, 'execute[apt-get update]', :immediately
  not_if 'test -f /etc/apt/sources.list.d/chris-lea-redis-server-precise.list'
end

package 'redis-server'

directory "/var/lib/redis" do
  owner "redis"
  group "redis"
  mode "0750"
  recursive true
end

template "/etc/redis/redis.conf" do
  source "redis.conf.erb"
  owner  "root"
  group  "root"
  mode   "0644"
  notifies :restart, "service[redis-server]"
end

service "redis-server" do
  supports restart: true
  action [:enable, :start]
end

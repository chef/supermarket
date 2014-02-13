#
# Author:: Seth Vargo (<sethvargo@gmail.com>)
# Recipe:: vagrant
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

node.set['secret_key_base'] = 'development'
node.set['devise_secret_key'] = 'development'
node.set['postgres']['auth_method'] = 'trust'
node.set['postgres']['user'] = 'vagrant'
node.set['postgres']['password'] = 'vagrant'
node.set['postgres']['database'] = 'supermarket_development'
node.set['redis']['maxmemory'] = '64mb'
node.set['sidekiq']['concurrency'] = '25'

include_recipe 'supermarket::_editors'
include_recipe 'supermarket::_node'
include_recipe 'supermarket::_postgres'
include_recipe 'supermarket::_redis'
include_recipe 'supermarket::_git'
include_recipe 'supermarket::_ruby'

execute 'dotenv[setup]' do
  user "vagrant"
  cwd "/supermarket"
  command 'cp .env.example .env'
  not_if { ::File.exists?('/supermarket/.env') }
end

execute 'bundle[install]' do
  cwd '/supermarket'
  command 'bundle install --path vendor'
  not_if '(cd /supermarket && bundle check)'
end

#
# Cookbook Name:: supermarket
# Attributes:: default
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

# Top-level attributes
default['supermarket']['config_filename'] = '/etc/supermarket/supermarket.rb'
default['supermarket']['install_directory'] = '/opt/supermarket'
default['supermarket']['log_directory'] = '/var/log/supermarket'
default['supermarket']['var_directory'] = '/var/opt/supermarket'
default['supermarket']['user'] = 'supermarket'
default['supermarket']['group'] = 'supermarket'

# Enterprise
#
# The "enterprise" cookbook provides recipes and resources we can use for this
# app.
#
default['enterprise']['name'] = 'supermarket'
# Enterprise uses install_path internally, but we use install_directory because
# it's more consistent. Alias it here so both work.
default['supermarket']['install_path'] = node['supermarket']['install_directory']
# An identifier used in /etc/inittab (default is 'SV'). Needs to be a unique
# (for the file) sequence of 1-4 characters.
default['supermarket']['sysvinit_id'] = 'SUP'

# Postgres
default['supermarket']['postgresql']['enable'] = true
default['supermarket']['postgresql']['username'] = node['supermarket']['user']
default['supermarket']['postgresql']['data_directory'] = "#{node['supermarket']['var_directory']}/postgresql/9.3/data"
# Logs
default['supermarket']['postgresql']['log_directory'] = "#{node['supermarket']['log_directory']}/postgresql"
default['supermarket']['postgresql']['log_rotation']['file_maxbytes'] = 104857600
default['supermarket']['postgresql']['log_rotation']['num_to_keep'] = 10
# DB settings
default['supermarket']['postgresql']['checkpoint_completion_target'] = 0.5
default['supermarket']['postgresql']['checkpoint_segments'] = 3
default['supermarket']['postgresql']['checkpoint_timeout'] = '5min'
default['supermarket']['postgresql']['checkpoint_warning'] = '30s'
default['supermarket']['postgresql']['effective_cache_size'] = '128MB'
default['supermarket']['postgresql']['listen_address'] = '127.0.0.1'
default['supermarket']['postgresql']['max_connections'] = 350
default['supermarket']['postgresql']['md5_auth_cidr_addresses'] = ['127.0.0.1/32', '::1/128']
default['supermarket']['postgresql']['port'] = 15432
default['supermarket']['postgresql']['shared_buffers'] = "#{(node['memory']['total'].to_i / 4) / (1024)}MB"
default['supermarket']['postgresql']['work_mem'] = "8MB"

# Redis
default['supermarket']['redis']['enable'] = true
default['supermarket']['redis']['directory'] = "#{node['supermarket']['var_directory']}/redis"
default['supermarket']['redis']['log_directory'] = "#{node['supermarket']['log_directory']}/redis"
default['supermarket']['redis']['log_rotation']['file_maxbytes'] = 104857600
default['supermarket']['redis']['log_rotation']['num_to_keep'] = 10
default['supermarket']['redis']['port'] = 16379

# Runit

# This is missing from the enterprise cookbook
# see (https://github.com/opscode-cookbooks/enterprise-chef-common/pull/17)
default['runit']['svlogd_bin'] = "#{node['supermarket']['install_directory']}/embedded/bin/svlogd"

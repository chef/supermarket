#
# Cookbook Name:: supermarket
# Recipe:: config
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

directory File.dirname(node['supermarket']['config_filename']) do
  user 'root'
  group 'root'
end

template node['supermarket']['config_filename'] do
  source 'supermarket.rb.erb'
  user 'root'
  group 'root'
  mode '0644'
  action :create_if_missing
end

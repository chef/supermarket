#
# Author:: Tristan O'Neil (<tristanoneil@gmail.com>)
# Recipe:: runit
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

package 'runit'

directory '/etc/service' do
  mode '0755'
  recursive true
end

%w(unicorn sidekiq).each do |service|
  directory "/etc/sv/#{service}" do
    mode '0755'
    recursive true
  end

  template "/etc/sv/#{service}/run" do
    source "#{service}.sv.erb"
    mode '0755'
  end

  link "/etc/service/#{service}" do
    to "/etc/sv/#{service}"
  end
end

service 'unicorn' do
  restart_command 'sv t unicorn'
end

service 'sidekiq' do
  restart_command 'sv t sidekiq'
end

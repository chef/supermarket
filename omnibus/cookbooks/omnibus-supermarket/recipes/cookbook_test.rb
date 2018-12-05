#
# Cookbook Name:: omnibus-supermarket
# Recipe:: cookbook_test
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

# This recipe is used to test the internal cookbook for the Supermarket Omnibus
# packages. It installs a supermarket package, copies the local cookbooks
# into Supermarket's embedded cookbooks directory, and runs commands to exercise
# the cookbooks with integration tests.

# If attributes are defined for packages, install them
package_path = node['supermarket']['test']['package_path'] || '/tmp/packages'
version_to_install = node['supermarket']['test']['version_to_install'] || 'nope_set_VERSION_TO_INSTALL'

case node['platform_family']
when 'debian'
  dpkg_package 'supermarket' do
    source "#{package_path}/supermarket_#{version_to_install}-1_amd64.deb"
  end
when 'rhel'
  rpm_package 'supermarket' do
    source "#{package_path}/supermarket-#{version_to_install}-1.el#{node['platform_version'].to_i}.x86_64.rpm"
  end
end

directory '/etc/supermarket'

file '/etc/supermarket/supermarket.json' do
  content node['supermarket']['ingredient_config'].to_json
end

# Remove installed cookbooks and replace them with local versions
Dir['/opt/supermarket/embedded/cookbooks/*'].each do |dir|
  directory dir do
    action :delete
    recursive true
    only_if { File.directory?(dir) }
  end
end

# Sync the local cookbooks into embedded
execute 'rsync -avz /tmp/kitchen/cookbooks/* /opt/supermarket/embedded/cookbooks/'

# Put the tests back into omnibus-supermarket so that `supermarket-ctl test` works
# kitchen removes them by default when copying cookbooks to /tmp/kitchen/cookbooks
execute 'rsync -avz /tmp/omnibus-supermarket-cookbook/test /opt/supermarket/embedded/cookbooks/omnibus-supermarket'

# Reconfigure the app
execute 'supermarket-ctl reconfigure'

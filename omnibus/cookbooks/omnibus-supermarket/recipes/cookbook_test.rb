#
# Cookbook Name:: supermarket
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
deb_package_path = node['supermarket']['test']['deb_package_path']
rpm_package_path = node['supermarket']['test']['rpm_package_path']

package 'supermarket' do
  case node['platform_family']
  when 'debian'
    provider Chef::Provider::Package::Dpkg
    source deb_package_path
    only_if { deb_package_path }
  when 'rhel'
    provider Chef::Provider::Package::Rpm
    source rpm_package_path
    only_if { rpm_package_path }
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
# Test kitchen excludes the test directory but puts it in /tmp/busser when verified
execute 'rsync -avz /tmp/busser/suites/serverspec/* /opt/supermarket/embedded/cookbooks/omnibus-supermarket/test/integration/default/serverspec/' do
  only_if { File.directory? '/tmp/busser/suites/serverspec' }
end

# Reconfigure the app
execute 'supermarket-ctl reconfigure'

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

dpkg_package 'supermarket' do
  source deb_package_path
  only_if do
    deb_package_path && node['platform_family'] == 'debian'
  end
end

rpm_package 'supermarket' do
  source rpm_package_path
  options "--nogpgcheck"
  only_if do
    rpm_package_path && node['platform_family'] == 'rhel'
  end
end

# Remove installed cookbooks and replace them with local versions
execute 'rm -rf /opt/supermarket/embedded/cookbooks/*/'
execute 'cp -R /tmp/kitchen/cookbooks/* /opt/supermarket/embedded/cookbooks/'

# Reconfigure the app
execute 'supermarket-ctl reconfigure'

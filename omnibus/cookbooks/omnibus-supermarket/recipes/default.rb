#
# Cookbook:: supermarket
# Recipe:: default
#
# Copyright:: 2014 Chef Software, Inc.
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

%w(
  config
  log_management
  ssl
  postgresql
  redis
  nginx
  database
  app
).each do |service|
  if node['supermarket'].dig(service, 'external')
    begin
      # Perform any necessary configuration of the external service:
      include_recipe "omnibus-supermarket::#{service}-external"
    rescue Chef::Exceptions::RecipeNotFound
      raise "#{service} has the 'external' attribute set true, but does not currently support being run externally."
    end
    # Disable the actual local service since what is enabled is an
    # externally managed version. Given that bootstrap isn't
    # externalizable, we don't need special handling for it as we do
    # in the normal disable case below.
    component_runit_service service do
      action :disable
    end
  elsif node['supermarket'][service]['enable']
    include_recipe "omnibus-supermarket::#{service}"
  else
    # All non-enabled services get disabled;
    component_runit_service service do
      action :disable
    end
  end
end

# Write out a supermarket-running.json at the end of the run
file "#{node['supermarket']['config_directory']}/supermarket-running.json" do
  content Chef::JSONCompat.to_json_pretty('supermarket' => node['supermarket'])
  owner node['supermarket']['user']
  group node['supermarket']['group']
  mode '0600'
end

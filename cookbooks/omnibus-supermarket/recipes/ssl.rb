#
# Cookbook Name:: supermarket
# Recipe:: ssl
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

include_recipe 'omnibus-supermarket::config'

# Sets up SSL certificates. Creates a self-signed cert if none was provided.

[node['supermarket']['ssl']['directory'],
 "#{node['supermarket']['ssl']['directory']}/ca"].each do |dir|
  directory dir do
    owner node['supermarket']['user']
    group node['supermarket']['group']
    mode '0700'
  end
end

# A certificate has been supplied
if node['supermarket']['ssl']['certificate']
  # Link the standard CA cert into our certs directory
  link "#{node['supermarket']['ssl']['directory']}/cacert.pem" do
    to "#{node['supermarket']['install_directory']}/embedded/ssl/certs/cacert.pem"
  end
# No certificate has been supplied; generate one
else
  keyfile = "#{node['supermarket']['ssl']['directory']}/ca/#{node['supermarket']['fqdn']}.key"
  crtfile = "#{node['supermarket']['ssl']['directory']}/ca/#{node['supermarket']['fqdn']}.crt"
  signing_conf = "#{node['supermarket']['ssl']['directory']}/ca/#{node['supermarket']['fqdn']}-ssl.conf"

  file keyfile do
    content `#{node['supermarket']['ssl']['openssl_bin']} genrsa 2048`
    owner 'root'
    group 'root'
    mode '0640'
    action :create_if_missing
  end

  template signing_conf do
    source 'ssl-signing.conf.erb'
    owner 'root'
    group 'root'
    mode '0644'
    action :create_if_missing
  end

  ruby_block 'create certificate' do
    block do
      r = Chef::Resource::File.new(crtfile, run_context)
      r.owner 'root'
      r.group 'root'
      r.mode '0644'
      r.content `#{node['supermarket']['ssl']['openssl_bin']} req -config '#{signing_conf}' -new -x509 -nodes -sha1 -days 3650 -key #{keyfile}`
      r.not_if { File.exists?(crtfile) }
      r.run_action(:create)
    end
  end

  node.default['supermarket']['ssl']['certificate'] ||= crtfile
  node.default['supermarket']['ssl']['certificate_key'] ||= keyfile

  link "#{node['supermarket']['ssl']['directory']}/cacert.pem" do
    to crtfile
  end
end

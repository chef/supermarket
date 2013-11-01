#
# Author:: Seth Vargo (<sethvargo@gmail.com>)
# Recipe:: node
#
# Copyright 2013 Opscode, Inc.
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

# NodeJS is required because of the asset pipeline needs a valud JS runtime

Chef::Resource.send(:include, Chef::Mixin::ShellOut)

source_url = node['supermarket']['node']['source_url']
src_dir    = node['supermarket']['node']['src_dir']
version    = node['supermarket']['node']['version']
prefix     = node['supermarket']['node']['prefix']

%w[build-essential openssl libssl-dev pkg-config].each do |name|
  package name do
    action :install
  end
end

directory src_dir do
  action :create
end

remote_file "#{src_dir}/node-#{version}.tar.gz" do
  source source_url
  not_if do
    File.exists?("#{prefix}/bin/node") &&
    shell_out("#{prefix}/bin/node --version").stdout.include?(version.gsub('-', ''))
  end
end

execute "untar-node-#{version}" do
  command "tar -xvzf node-#{version}.tar.gz"
  cwd src_dir
  not_if { File.directory?("#{src_dir}/node-v#{version}") }
end

execute "compile-node-#{version}" do
  command "./configure --prefix=#{prefix} && make && make install"
  cwd "#{src_dir}/node-v#{version}"
  not_if do
    File.exists?("#{prefix}/bin/node") &&
    shell_out("#{prefix}/bin/node --version").stdout.include?(version.gsub('-', ''))
  end
end

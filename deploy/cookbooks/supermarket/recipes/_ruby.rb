#
# Author:: Seth Vargo (<sethvargo@gmail.com>)
# Recipe:: ruby
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

Chef::Resource.send(:include, Chef::Mixin::ShellOut)

source_url = node['supermarket']['ruby']['source_url']
src_dir    = node['supermarket']['ruby']['src_dir']
version    = node['supermarket']['ruby']['version']
prefix     = node['supermarket']['ruby']['prefix']

%w[build-essential zlib1g-dev libssl-dev libreadline6-dev libyaml-dev].each do |name|
  package name do
    action :install
  end
end

directory src_dir do
  action :create
end

remote_file "#{src_dir}/ruby-#{version}.tar.gz" do
  source source_url
  not_if do
    File.exists?("#{prefix}/bin/ruby") &&
    shell_out("#{prefix}/bin/ruby --version").stdout.include?(version.gsub('-', ''))
  end
end

execute "untar-ruby-#{version}" do
  command "tar -xvzf ruby-#{version}.tar.gz"
  cwd src_dir
  notifies :run, "execute[compile-ruby-#{version}]", :immediately
  not_if { File.directory?("#{src_dir}/ruby-#{version}") }
end

execute "compile-ruby-#{version}" do
  command "./configure --prefix=#{prefix} && make && make install"
  cwd "#{src_dir}/ruby-#{version}"
  notifies :reload, 'ohai[reload_ruby]', :immediately
  not_if do
    File.exists?("#{prefix}/bin/ruby") &&
    shell_out("#{prefix}/bin/ruby --version").stdout.include?(version.gsub('-', ''))
  end
end

ohai 'reload_ruby' do
  plugin 'ruby'
  action :nothing
end

gem_package 'bundler' do
  action :install
end

execute 'bundle install --path vendor' do
  cwd    '/vagrant'
  not_if 'bundle check'
end

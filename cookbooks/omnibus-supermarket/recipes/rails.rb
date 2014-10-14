#
# Cookbook Name:: supermarket
# Recipe:: rails
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

[node['supermarket']['rails']['log_directory'],
 "#{node['supermarket']['var_directory']}/rails/run"].each do |dir|
  directory dir do
    owner node['supermarket']['user']
    group node['supermarket']['group']
    mode '0700'
    recursive true
  end
end

if node['supermarket']['rails']['enable']
  component_runit_service 'rails' do
    package 'supermarket'
  end
else
  runit_service 'rails' do
    action :disable
  end
end

# Before and after fork blocks for Unicorn.
#
# We'll probably want to factor these out into something else when we do the
# same setup for Fieri.
before_fork = node['supermarket']['unicorn']['before_fork'] || <<EOF
  # When sent a USR2, Unicorn will suffix its pidfile with .oldbin and
  # immediately start loading up a new version of itself (loaded with a new
  # version of our app). This new Unicorn, before it forks workers, will check
  # to see if an .oldbin pidfile exists. If so, this means we've just booted up
  # a new Unicorn and need to tell the old one that it can now die. To do so
  # we send it a QUIT.
  #
  # Using this method we get 0 downtime deploys.
  old_pid = "#{node['supermarket']['unicorn']['pid']}.oldbin"

  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill('QUIT', File.read(old_pid).to_i)

      defined?(ActiveRecord::Base) &&
        ActiveRecord::Base.connection.disconnect!
     rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
EOF

after_fork = node['supermarket']['unicorn']['after_fork'] || <<EOF
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.establish_connection
EOF

template "#{node['supermarket']['var_directory']}/etc/unicorn.rb" do
  source 'unicorn.rb.erb'
  cookbook 'unicorn'
  owner node['supermarket']['user']
  group node['supermarket']['group']
  mode '0600'
  variables node['supermarket']['unicorn'].merge(
    :before_fork => before_fork, :after_fork => after_fork
  )
  notifies :restart, 'runit_service[rails]'
end

link "#{node['supermarket']['app_directory']}/config/unicorn.rb" do
  to "#{node['supermarket']['var_directory']}/etc/unicorn.rb"
end

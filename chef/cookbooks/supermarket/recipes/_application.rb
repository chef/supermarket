#
# Author:: Tristan O'Neil (<tristanoneil@gmail.com>)
# Recipe:: application
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

include_recipe 'supermarket::_apt'

app = data_bag_item(:apps, 'supermarket')

deploy_revision node['supermarket']['home'] do
  repo 'https://github.com/opscode/supermarket.git'
  revision app['revision']
  user 'supermarket'
  group 'supermarket'
  migrate true
  migration_command 'bundle exec rake db:migrate'
  environment 'RAILS_ENV' => 'production'
  action app['deploy_action'] || 'deploy'

  symlink_before_migrate '.env' => '.env'

  before_migrate do
    %w(pids log system public).each do |dir|
      directory "#{node['supermarket']['home']}/shared/#{dir}" do
        mode 0777
        recursive true
      end
    end

    template "#{release_path}/config/database.yml"

    template "#{node['supermarket']['home']}/shared/.env" do
      variables(app: app)
    end

    execute 'bundle install' do
      cwd release_path
      command 'bundle install --without test development --path=vendor/bundle'
    end
  end

  before_restart do
    execute 'asset:precompile' do
      environment 'RAILS_ENV' => 'production'
      cwd release_path
      command 'bundle exec rake assets:precompile'
    end
  end

  notifies :restart, 'service[unicorn]'
  notifies :restart, 'service[sidekiq]'
end

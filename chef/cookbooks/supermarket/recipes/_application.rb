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

application_directory = '/var/www/supermarket'

deploy_revision "#{application_directory}" do
  repo 'https://github.com/opscode/supermarket.git'
  revision "master"
  migrate true
  migration_command 'bundle exec rake db:migrate'
  environment 'RAILS_ENV' => 'production'

  symlink_before_migrate '.env' => '.env'

  before_migrate do
    %w{pids log system public}.each do |dir|
      directory "#{application_directory}/shared/#{dir}" do
        mode 0777
        recursive true
      end
    end

    sidekiq_pid = "#{application_directory}/shared/pids/sidekiq.pid"

    template "#{application_directory}/shared/.env"

    execute 'bundle install' do
      cwd release_path
      command 'bundle install --without test development'
    end

    execute 'quiet sidekiq' do
      cwd release_path
      command "bundle exec sidekiqctl quiet #{sidekiq_pid}"
      only_if "test -f #{sidekiq_pid}"
    end
  end

  before_restart do
    execute 'asset:precompile' do
      cwd release_path
      command 'export RAILS_ENV=production && bundle exec rake assets:precompile'
    end
  end

  restart do
    unicorn_pid = "#{release_path}/tmp/pids/unicorn.pid"
    sidekiq_pid = "#{release_path}/tmp/pids/sidekiq.pid"
    log_dir = "#{application_directory}/shared/log"

    execute 'stop unicorn' do
      command "kill `cat #{unicorn_pid}`"
      only_if { File.exist?(unicorn_pid) }
    end

    execute 'start unicorn' do
      cwd release_path
      command 'export RAILS_ENV=production && bundle exec unicorn -c config/unicorn/production.rb -D'
      not_if { File.exist?(unicorn_pid) }
    end

    execute 'stop sidekiq' do
      cwd release_path
      command "bundle exec sidekiqctl stop #{sidekiq_pid} 60"
      only_if "test -f #{sidekiq_pid}"
    end

    execute 'start sidekiq' do
      cwd release_path
      command "bundle exec sidekiq -d -P #{sidekiq_pid} -C /etc/sidekiq/sidekiq.yml -e production -t 30 -L #{log_dir}/sidekiq.log"
      not_if "test -f #{sidekiq_pid}"
    end
  end
end

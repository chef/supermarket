# encoding: utf-8
# copyright: 2017, Chef Software, Inc.
# license: All rights reserved

require_relative '../libraries/helper'

title 'Supermarket Smoke Tests'

%w(
  nginx
  postgresql
  rails
  redis
  sidekiq
).each do |component_service|
  describe runit_service(component_service, '/opt/supermarket/embedded/bin/sv') do
    it { should be_installed }
    it { should be_enabled }
  end
end

supermarket_version = fetch_supermarket_version

describe http("https://#{fetch_target_host}/status") do
  its('status') { should eq 200 }
end

describe json('/opt/supermarket/version-manifest.json') do
  its('build_version') { should eq supermarket_version }
end

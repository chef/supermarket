require 'spec_helper'

describe 'omnibus-supermarket::log_management' do
  describe file(property['supermarket']['var_directory'] + '/etc/logrotate.d') do
    it { should be_directory }
  end

  describe file(property['supermarket']['var_directory'] + '/etc/logrotate.conf') do
    it { should be_file }
    its(:content) { should match /#{'include ' + property['supermarket']['var_directory'] + '/etc/logrotate.d'}/ }
  end

  describe file('/etc/cron.hourly/supermarket_logrotate') do
    it { should be_file }
    its(:content) { should match /#{'logrotate /var/opt/supermarket/etc/logrotate.conf'}/ }
  end

end

require 'spec_helper'

describe 'omnibus-supermarket::nginx' do
  describe port(property['supermarket']['nginx']['ssl_port']) do
    if property['supermarket']['nginx']['enable']
      it { should be_listening.with('tcp') }
    else
      it { should_not be_listening.with('tcp') }
    end
  end

  describe file(property['supermarket']['var_directory'] + '/etc/logrotate.d/nginx') do
    it { should be_file }
    its(:content) { should match /#{property['supermarket']['nginx']['log_directory'] + '/\*.log'}/}
  end
end

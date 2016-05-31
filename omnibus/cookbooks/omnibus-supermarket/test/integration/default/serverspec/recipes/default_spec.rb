require 'spec_helper'

describe 'omnibus-supermarket::default' do
  describe file(property['supermarket']['var_directory'] + '/cache') do
    it { should be_directory }
  end

  describe file(property['supermarket']['install_directory'] + '/embedded/cookbooks/local-mode-cache') do
    it { should_not exist }
  end
end

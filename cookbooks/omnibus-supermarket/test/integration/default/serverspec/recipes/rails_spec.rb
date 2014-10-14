require 'spec_helper'

describe 'omnibus-supermarket::rails' do
  describe port(13000) do
    it { should be_listening.with('tcp') }
  end
end

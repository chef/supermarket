require 'spec_helper'

describe 'omnibus-supermarket::redis' do
  describe port(16379) do
    it { should be_listening.with('tcp') }
  end
end

require 'spec_helper'

describe 'omnibus-supermarket::nginx' do
  describe port(443) do
    it { should be_listening.with('tcp') }
  end
end

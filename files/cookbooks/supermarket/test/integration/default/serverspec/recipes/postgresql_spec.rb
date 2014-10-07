require 'spec_helper'

describe 'supermarket::postgresql' do
  describe port(15432) do
    it { should be_listening.with('tcp') }
  end
end

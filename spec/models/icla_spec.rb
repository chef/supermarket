require 'spec_helper'

describe Icla do
  it { should validate_uniqueness_of(:version) }

  describe '.latest' do
    it 'should get the Icla with the configured version' do
      version = ENV['ICLA_VERSION']
      ENV['ICLA_VERSION'] = '1'

      expect(Icla).to receive(:find_by_version).with('1')
      Icla.latest

      ENV['ICLA_VERSION'] = version
    end
  end
end

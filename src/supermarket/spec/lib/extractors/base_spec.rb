require 'spec_helper'

#
# Test stub class for testing extractor objects.
#
class TestExtractor < Extractor::Base; end

describe Extractor::Base do
  describe '.load' do
    it 'raises an exception when the extractor does not exist' do
      expect { described_class.load('provider' => 'fake') }
        .to raise_error(RuntimeError, 'Fake is not a valid extractor!')
    end

    it 'returns an instance of the extractor' do
      expect(described_class.load('provider' => 'test')).to be_a(described_class)
    end
  end

  describe '#signature' do
    it 'returns a hash with the correct keys' do
      instance = TestExtractor.new('provider' => 'test')
      expect(instance.signature).to eq(provider: 'test', uid: nil)
    end
  end
end

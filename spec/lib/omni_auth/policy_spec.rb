require 'spec_helper'
require 'omni_auth/policy'

describe OmniAuth::Policy do
  let(:klass) { Class.new { include OmniAuth::Policy } }

  before { described_class.class_variable_set(:@@policies, {}) }

  describe '.register' do
    it 'adds the class registry' do
      described_class.register(:klass, klass)
      expect(described_class.policies).to have_key(:klass)
      expect(described_class.policies[:klass]).to eq(klass)
    end

    it 'behaves correctly when given a string' do
      described_class.register('klass', klass)
      expect(described_class.policies).to have_key(:klass)
      expect(described_class.policies[:klass]).to eq(klass)
    end
  end

  describe '.load' do
    it 'raises an exception when there are no policies' do
      expect {
        described_class.load('provider' => 'foo')
      }.to raise_error(RuntimeError, ':foo is not a valid key!')
    end

    it 'returns an instance of the provider' do
      described_class.register(:klass, klass)
      expect(described_class.load('provider' => 'klass')).to be_a(described_class)
    end
  end

  describe '#signature' do
    it 'returns a hash with the correct keys' do
      instance = klass.new('provider' => 'klass')
      expect(instance.signature).to eq(provider: 'klass', uid: nil)
    end
  end
end

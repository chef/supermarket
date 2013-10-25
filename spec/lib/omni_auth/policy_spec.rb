require 'spec_helper'
require 'omni_auth/policy'

#
# Test stub class for testing policy objects.
#
class OmniAuth::Policies::TestPolicy
  include OmniAuth::Policy
end

describe OmniAuth::Policy do
  describe '.load' do
    it 'raises an exception when there are no policies' do
      expect {
        described_class.load('provider' => 'not_a_policy')
      }.to raise_error(RuntimeError, 'NotAPolicy is not a valid policy!')
    end

    it 'returns an instance of the provider' do
      expect(described_class.load('provider' => 'test_policy')).to be_a(described_class)
    end
  end

  describe '#signature' do
    it 'returns a hash with the correct keys' do
      instance = OmniAuth::Policies::TestPolicy.new('provider' => 'test_policy')
      expect(instance.signature).to eq(provider: 'test_policy', uid: nil)
    end
  end
end

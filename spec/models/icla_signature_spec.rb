require 'spec_helper'

describe IclaSignature do
  context 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:icla) }
  end

  context 'validations' do
    it { should validate_presence_of(:user) }
    it { should validate_acceptance_of(:agreement) }
  end

  context 'callbacks' do
    it 'sets the value of signed_at' do
      time = Time.at(680241600)
      Time.stub(:now).and_return(time)

      icla_signature = create(:icla_signature)
      expect(icla_signature.signed_at).to eq(time)
    end
  end
end

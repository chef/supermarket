require 'spec_helper'

describe User do
  context 'associations' do
    it { should have_many(:accounts) }
    it { should have_many(:addresses) }
    it { should have_many(:emails) }
    it { should have_many(:icla_signatures) }
    it { should have_one(:primary_email) }
  end

  context 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
  end

  context 'callbacks' do
    it 'normalizes the phone number' do
      user = build(:user, phone: '(888) 888-8888')
      user.valid? # force running validations to invoke the callback
      expect(user.phone).to eq('8888888888')
    end
  end

  context 'instance methods' do
    describe '#signed_icla?' do
      it 'is true when there is an icla signature' do
        user = build(:user, icla_signatures: [build(:icla_signature)])
        expect(user.signed_icla?).to be_true
      end

      it 'is false when there is not an icla signature' do
        user = build(:user, icla_signatures: [])
        expect(user.signed_icla?).to be_false
      end
    end
  end
end

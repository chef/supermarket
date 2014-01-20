require 'spec_helper'

describe User do
  context 'associations' do
    it { should have_many(:accounts) }
    it { should have_many(:emails) }
    it { should have_many(:icla_signatures) }
    it { should belong_to(:primary_email) }
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

  describe '#is_admin_of_organization?' do
    it 'is true when the user is an admin of the given organization' do
      organization_user = create(:organization_user, admin: true)
      user = organization_user.user
      organization = organization_user.organization

      expect(user.is_admin_of_organization?(organization)).to be_true
    end

    it 'is false when the user is not an admin of the given organization' do
      organization_user = create(:organization_user, admin: false)
      user = organization_user.user
      organization = organization_user.organization

      expect(user.is_admin_of_organization?(organization)).to be_false
    end
  end
end

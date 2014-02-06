require 'spec_helper'

describe User do
  context 'associations' do
    it { should have_many(:accounts) }
    it { should have_many(:icla_signatures) }
  end

  context 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }

    context 'when signing or having already signed a icla' do
      before { double(:signed_icla?) { true} }

      it { should validate_presence_of(:phone) }
      it { should validate_presence_of(:address_line_1) }
      it { should validate_presence_of(:city) }
      it { should validate_presence_of(:state) }
      it { should validate_presence_of(:zip) }
      it { should validate_presence_of(:country) }
    end
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
      contributor = create(:contributor, admin: true)
      user = contributor.user
      organization = contributor.organization

      expect(user.is_admin_of_organization?(organization)).to be_true
    end

    it 'is false when the user is not an admin of the given organization' do
      contributor = create(:contributor, admin: false)
      user = contributor.user
      organization = contributor.organization

      expect(user.is_admin_of_organization?(organization)).to be_false
    end
  end

  describe '#account_from_oauth' do
    it 'returns an account' do
      user = build(:user)
      auth = { 'provider' => 'github', 'info' => { 'username' => 'johndoe' },
        'credentials' => { 'token' => 'sometoken' }, 'uid' => 'someuid' }

      account = user.account_from_oauth(auth)

      expect(account.provider).to eql('github')
      expect(account.uid).to eql('someuid')
      expect(account.oauth_token).to eql('sometoken')
    end
  end

  describe '#linked_github_account?' do

    let(:user) { create(:user) }

    it 'is false when the user has not linked a GitHub account' do
      expect(user.linked_github_account?).to eql(false)
    end

    it 'is true when the user has linked a GitHub account' do
      user.account_from_oauth(OmniAuth.config.mock_auth[:github]).save!

      expect(user.linked_github_account?).to eql(true)
    end

  end
end

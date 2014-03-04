require 'spec_helper'

describe User do
  context 'associations' do
    it { should have_many(:accounts) }
    it { should have_many(:icla_signatures) }
  end

  context 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
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

  describe '#latest_icla_signature' do
    it 'returns the latest ICLA signature' do
      one_year_ago = create(:icla_signature, signed_at: 1.year.ago)
      one_month_ago = create(:icla_signature, signed_at: 1.month.ago)

      user = create(:user, icla_signatures: [one_year_ago, one_month_ago])
      expect(user.latest_icla_signature).to eql(one_month_ago)
    end
  end

  describe '#signed_ccla?' do
    it 'is true when there is a ccla signature' do
      user = build(:user, ccla_signatures: [build(:ccla_signature)])
      expect(user.signed_ccla?).to be_true
    end

    it 'is false when there is not a ccla signature' do
      user = build(:user, ccla_signatures: [])
      expect(user.signed_ccla?).to be_false
    end
  end

  describe '#signed_cla' do
    it 'is it true when there is an ccla signature and a icla signature' do
      user = build(
        :user,
        ccla_signatures: [build(:ccla_signature)],
        icla_signatures: [build(:icla_signature)]
      )

      expect(user.signed_cla?).to be_true
    end

    it 'is it true when there is an ccla signature' do
      user = build(
        :user,
        ccla_signatures: [build(:ccla_signature)]
      )

      expect(user.signed_cla?).to be_true
    end

    it 'is it true when there is no ccla or icla signature' do
      user = build(
        :user,
        icla_signatures: [],
        ccla_signatures: []
      )

      expect(user.signed_cla?).to be_false
    end
  end

  describe '#admin_of_organization?' do
    it 'is true when the user is an admin of the given organization' do
      contributor = create(:contributor, admin: true)
      user = contributor.user
      organization = contributor.organization

      expect(user.admin_of_organization?(organization)).to be_true
    end

    it 'is false when the user is not an admin of the given organization' do
      contributor = create(:contributor, admin: false)
      user = contributor.user
      organization = contributor.organization

      expect(user.admin_of_organization?(organization)).to be_false
    end
  end

  describe '#account_from_oauth' do
    it 'returns an account' do
      user = build(:user)
      auth = {
        'provider' => 'github',
        'info' => { 'username' => 'johndoe' },
        'credentials' => { 'token' => 'sometoken' },
        'uid' => 'someuid'
      }

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

  describe '#verified_commit_author_identities' do

    it "returns the user's commit author identities who have signed a CLA" do
      commit_author = create(:commit_author, login: 'joedoe', signed_cla: true)
      user = create(:user)
      account = create(
        :account,
        user: user,
        provider: 'github',
        username: 'joedoe'
      )

      expect(user.verified_commit_author_identities).
        to eql([commit_author])
    end

    it "does not return the user's commit author identities who have not signed a CLA" do
      commit_author = create(:commit_author, login: 'joedoe', signed_cla: false)
      user = create(:user)
      account = create(
        :account,
        user: user,
        provider: 'github',
        username: 'joedoe'
      )

      expect(user.verified_commit_author_identities).
        to eql([])
    end
  end

  describe '#unverified_commit_author_identities' do

    it "returns the user's commit author identities who have not signed a CLA" do
      commit_author = create(:commit_author, login: 'joedoe', signed_cla: false)
      user = create(:user)
      account = create(
        :account,
        user: user,
        provider: 'github',
        username: 'joedoe'
      )

      expect(user.unverified_commit_author_identities).
        to eql([commit_author])
    end

    it "does not return the user's commit author identities who have signed a CLA" do
      commit_author = create(:commit_author, login: 'joedoe', signed_cla: true)
      user = create(:user)
      account = create(
        :account,
        user: user,
        provider: 'github',
        username: 'joedoe'
      )

      expect(user.unverified_commit_author_identities).
        to eql([])
    end
  end

  describe '.find_by_github_login' do
    it 'returns the user with that GitHub login' do
      user = create(:user)
      account = create(:account, user: user, provider: 'github')

      expect(User.find_by_github_login(account.username)).to eql(user)
    end

    it 'returns a new user if there is no user with that GitHub login' do
      expect(User.find_by_github_login('trex').persisted?).to be_false
    end
  end
end

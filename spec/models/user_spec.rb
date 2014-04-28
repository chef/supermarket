require 'spec_helper'

describe User do
  context 'associations' do
    it { should have_many(:accounts) }
    it { should have_many(:icla_signatures) }
    it { should have_many(:owned_cookbooks) }
    it { should have_many(:cookbook_collaborators) }
    it { should have_many(:collaborated_cookbooks) }
  end

  context 'validations' do
    it { should validate_presence_of(:email) }
  end

  it 'should find a cookbook collaborator given a cookbook' do
    user = create(:user)
    cookbook = create(:cookbook)
    cookbook_collaborator = CookbookCollaborator.create! cookbook: cookbook, user: user
    expect(user.reload.collaborator_for_cookbook(cookbook)).to eql(cookbook_collaborator)
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

  describe '.search' do
    let!(:jimmy) do
      create(
        :user,
        first_name: 'Jimmy',
        last_name: 'Jammy',
        email: 'jimmyjammy@example.com'
      )
    end

    let!(:jim) do
      create(
        :user,
        first_name: 'Jim',
        last_name: 'McJimmerton',
        email: 'jimmcjimmerton@example.com'
      )
    end

    before do
      jimmy.accounts << create(:account, provider: 'chef_oauth2', username: 'jimmyjammy')
      jim.accounts << create(:account, provider: 'chef_oauth2', username: 'jimmcjimmerton')
    end

    it 'returns users with a similar first name' do
      expect(User.search('jim')).to include(jimmy)
      expect(User.search('jim')).to include(jim)
    end

    it 'returns users with a similar last name' do
      expect(User.search('jam')).to include(jimmy)
      expect(User.search('jam')).to_not include(jim)
    end

    it 'returns users with a similar email address' do
      expect(User.search('example')).to include(jimmy)
      expect(User.search('example')).to include(jim)
    end

    it 'returns users with a similar chef account username' do
      expect(User.search('jimmyjam')).to include(jimmy)
      expect(User.search('jimmcji')).to include(jim)
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
      auth = OmniAuth.config.mock_auth[:github]

      account = user.account_from_oauth(auth)

      expect(account.provider).to eql('github')
      expect(account.uid).to eql(auth['uid'])
      expect(account.oauth_token).to eql(auth['credentials']['token'])
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

  describe '#username' do
    it 'returns the chef username for the user' do
      account = create(:account, username: 'fanny', provider: 'chef_oauth2')

      expect(account.user.username).to eql('fanny')
    end

    it 'returns a blank string if the user has unlinked their Chef ID' do
      user = create(:user)
      user.accounts.destroy_all # unlink all accounts aka destroy them

      expect(user.username).to eql('')
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

  describe '.find_or_create_from_chef_oauth' do
    let(:auth) do
      OmniAuth.config.mock_auth[:chef_oauth2]
    end

    context 'when the user does not already exist' do
      it 'creates a record' do
        expect do
          User.find_or_create_from_chef_oauth(auth)
        end.to change(User, :count).by(1)
      end

      it "sets the user's public key and name" do
        user = User.find_or_create_from_chef_oauth(auth)

        expect(user.public_key).to eql(auth['info']['public_key'])
        expect(user.first_name).to eql(auth['info']['first_name'])
        expect(user.last_name).to eql(auth['info']['last_name'])
      end

      it 'ties the user and account together' do
        user = User.find_or_create_from_chef_oauth(auth)

        expect(user.accounts.reload.count).to eql(1)
      end
    end

    context 'when the user already exists' do
      before do
        User.find_or_create_from_chef_oauth(auth)
      end

      it 'does not create a record' do
        expect do
          User.find_or_create_from_chef_oauth(auth)
        end.to_not change(User, :count)
      end

      it "updates the user's name and public key" do
        new_auth = auth.dup.tap do |auth|
          auth[:info][:first_name] = 'Sous'
          auth[:info][:last_name] = 'Chef'
          auth[:info][:public_key] = 'ssh-rsa blahblahblah'
        end

        user = User.find_or_create_from_chef_oauth(new_auth)

        expect(user.first_name).to eql('Sous')
        expect(user.last_name).to eql('Chef')
        expect(user.public_key).to eql('ssh-rsa blahblahblah')
      end
    end
  end

  describe '.with_email' do
    it 'finds users with the given email address' do
      user = create(:user, email: 'with_email@example.com')
      user2 = create(:user, email: 'with_email2@example.com')

      expect(User.with_email('with_email@example.com')).to include(user)
      expect(User.with_email('with_email@example.com')).to_not include(user2)
    end
  end
end

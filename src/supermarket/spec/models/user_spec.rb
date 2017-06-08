require 'spec_helper'

describe User do
  context 'associations' do
    it { should have_many(:accounts) }
    it { should have_many(:owned_cookbooks) }
    it { should have_many(:collaborators) }
    it { should have_many(:collaborated_cookbooks) }
    it { should have_many(:cookbook_followers) }
    it { should have_many(:followed_cookbooks) }
    it { should have_many(:tools) }
    it { should have_many(:group_members) }
    it { should have_many(:memberships) }
  end

  context 'validations' do
    it { should validate_presence_of(:email) }
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

    it 'returns users with a similar github username' do
      jimmy.accounts << create(:account, provider: 'github', username: 'goofygithubuser')
      jim.accounts << create(:account, provider: 'github', username: 'someotherdude')
      expect(User.search('goofygithubuser')).to include(jimmy)
      expect(User.search('someotherdude')).to include(jim)
    end
  end

  describe '#followed_cookbook_versions' do
    it 'returns all cookbook versions of a followed cookbook' do
      user = create(:user)
      redis = create(:cookbook)
      yum = create(:cookbook)
      create(:cookbook_follower, user: user, cookbook: redis)
      create(:cookbook_follower, user: user, cookbook: yum)

      expect(user.followed_cookbook_versions).to include(*redis.cookbook_versions)
      expect(user.followed_cookbook_versions).to include(*yum.cookbook_versions)
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

  describe '#username' do
    it 'returns the chef username for the user' do
      user = create(:user)
      account = user.accounts.for('chef_oauth2').first
      account.update_attributes(username: 'fanny')

      expect(user.username).to eql('fanny')
    end

    it 'returns a blank string if the user has unlinked their Chef ID' do
      user = create(:user)
      user.accounts.destroy_all # unlink all accounts aka destroy them

      expect(user.username).to eql('')
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

      it "sets the user's public key, name, and email" do
        user = User.find_or_create_from_chef_oauth(auth).reload

        expect(user.public_key).to eql(auth['info']['public_key'])
        expect(user.first_name).to eql(auth['info']['first_name'])
        expect(user.last_name).to eql(auth['info']['last_name'])
        expect(user.email).to eql(auth['info']['email'])
      end

      it "sets the chef account's oauth information" do
        user = User.find_or_create_from_chef_oauth(auth).reload
        account = user.chef_account

        expected_expiration = Time.zone.at(OmniAuthControl::EXPIRATION)

        expect(account.username).to eql(auth['info']['username'])
        expect(account.uid).to eql(auth['uid'])
        expect(account.oauth_token).to eql(auth['credentials']['token'])
        expect(account.oauth_expires).to eql(expected_expiration)
        expect(account.oauth_refresh_token).to eql(auth['credentials']['refresh_token'])
        expect(user.email).to eql(auth['info']['email'])
      end

      it 'ties the user and account together' do
        user = User.find_or_create_from_chef_oauth(auth).reload

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

        user = User.find_or_create_from_chef_oauth(new_auth).reload

        expect(user.first_name).to eql('Sous')
        expect(user.last_name).to eql('Chef')
        expect(user.public_key).to eql('ssh-rsa blahblahblah')
      end

      it "updates the chef account's oauth information" do
        expiry = 1.hour.from_now
        new_auth = auth.dup.tap do |auth|
          auth[:credentials][:token] = 'cool_token'
          auth[:credentials][:expires_at] = expiry.to_i
          auth[:credentials][:refresh_token] = 'fresh_refresh'
        end

        user = User.find_or_create_from_chef_oauth(new_auth).reload
        account = user.chef_account

        expected_expiration = expiry.utc.to_i
        actual_expiration = account.oauth_expires.utc.to_i

        expect(account.username).to eql(auth['info']['username'])
        expect(account.uid).to eql(auth['uid'])
        expect(account.oauth_token).to eql('cool_token')
        expect(actual_expiration).to eql(expected_expiration)
        expect(account.oauth_refresh_token).to eql('fresh_refresh')
        expect(user.email).to eql(auth['info']['email'])
      end
    end
  end

  describe '#name' do
    it 'joins the first and last name with a space' do
      user = create(:user, first_name: 'Jimmy', last_name: 'Smith')
      expect(user.name).to eql('Jimmy Smith')
    end

    it 'displays the name correctly even if there is only a first name' do
      user = create(:user, first_name: 'Jimmy', last_name: nil)
      expect(user.name).to eql('Jimmy')
    end

    it 'displays the name correctly even if there is only a last name' do
      user = create(:user, first_name: nil, last_name: 'Smith')
      expect(user.name).to eql('Smith')
    end

    it 'displays the name correctly if there are multiple names for first or last name' do
      user = create(:user, first_name: 'Jimmy Joe', last_name: 'Billy Bob')
      expect(user.name).to eql('Jimmy Joe Billy Bob')
    end

    it 'displays the username if there are no names at all' do
      user = create(:user, first_name: nil, last_name: nil, create_chef_account: false)
      create(:account, username: 'superman', user: user, provider: 'chef_oauth2')
      expect(user.name).to eql('superman')
    end

    it 'displays the username if first and last names are empty' do
      user = create(:user, first_name: '', last_name: '', create_chef_account: false)
      create(:account, username: 'superman', user: user, provider: 'chef_oauth2')
      expect(user.name).to eql('superman')
    end
  end

  describe '#update_install_preference' do
    it 'returns true if the user is saved' do
      user = build(:user)

      expect(user.update_install_preference('knife')).to be true
    end

    it 'returns false if the preference is not a valid one' do
      user = build(:user)

      expect(user.update_install_preference('wut')).to be false
    end

    it 'updates the install preference to what is specified' do
      user = create(:user)
      user.update_install_preference('knife')

      expect(user.reload.install_preference).to eql('knife')
    end
  end

  describe '#public_key_signature' do
    it 'returns the hex MD5 hash of the DER form of the user\'s public key' do
      user = create(:user, public_key: File.read('spec/support/key_fixtures/valid_public_key.pub'))
      expect(user.public_key_signature).to eq("0f:d2:d4:d9:76:14:ab:8e:bd:67:87:d5:d6:a7:24:29")
    end

    it 'returns nil if there is no public key on the user\'s account' do
      user = create(:user, public_key: nil)
      expect(user.public_key_signature).to be_nil
    end
  end
end

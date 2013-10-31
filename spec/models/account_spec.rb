require 'spec_helper'

describe Account do
  context 'associations' do
    it { should belong_to(:user) }
  end

  context 'validations' do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:uid) }
    it { should validate_presence_of(:provider) }
  end

  describe '.for' do
    let!(:githubs) { create_list(:account, 2, provider: 'github') }
    let!(:twitters) { create_list(:account, 3, provider: 'twitter') }

    it 'returns an empty array when there are no accounts' do
      expect(Account.for(:non_existent)).to be_empty
    end

    it 'returns the correct accounts' do
      expect(Account.for(:github)).to eq(githubs)
      expect(Account.for(:twitter)).to eq(twitters)
    end
  end

  describe '.from_oauth' do
    let(:auth) { OmniAuth.config.mock_auth[:default].dup }
    let(:account) { Account.first }

    it 'updates the primary email' do
      auth['info']['email'] = 'johndoe@example.com'
      user = create(:user)

      Account.from_oauth(auth, user)
      expect(user.primary_email.email).to eq('johndoe@example.com')
    end

    it 'does not change the exiting primary email' do
      auth['info']['email'] = 'johndoe@example.com'
      user = create(:user, primary_email: create(:email, email: 'john@example.com'))

      Account.from_oauth(auth, user)
      expect(user.primary_email.email).to eq('john@example.com')
    end

    context 'when a user is given' do
      let(:user) { create(:user) }

      it 'uses the given user' do
        Account.from_oauth(auth, user)

        expect(account).to be
        expect(account.user).to eq(user)
      end

      it 'creates a single user' do
        Account.from_oauth(auth, user)
        expect(User.count).to eq(1)
      end
    end

    context 'when an email already exists' do
      let(:address) { 'johndoe@example.com' }
      let(:user)    { create(:user) }

      before { create(:email, email: address, user: user) }

      it 'uses the user from the email' do
        auth['info']['email'] = address
        Account.from_oauth(auth)

        expect(account).to be
        expect(account.user).to eq(user)
      end
    end

    context 'when an icla signature exists' do
      let(:address) { 'johndoe@example.com' }
      let(:user)    { create(:user) }

      before { create(:icla_signature, email: address, user: user) }

      it 'uses the user from the signature' do
        auth['info']['email'] = address
        Account.from_oauth(auth)

        expect(account).to be
        expect(account.user).to eq(user)
      end
    end

    context 'when no user exists' do
      it 'creates a new user' do
        expect { Account.from_oauth(auth) }.to change(User, :count).by(1)
      end
    end

    context 'when something in the transaction fails' do
      it 'does not save any of the objects' do
        auth['credentials']['token'] = nil

        expect { Account.from_oauth(bad_auth) }.to raise_error

        expect(Account.count).to eq(0)
        expect(User.count).to eq(0)
      end
    end
  end
end

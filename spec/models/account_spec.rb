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
    let(:auth) { OmniAuth.config.mock_auth[:default] }

    it 'creates the account' do
      expect { Account.from_oauth(auth) }.to change(Account, :count).by(1)
    end

    it 'creates the user' do
      expect { Account.from_oauth(auth) }.to change(User, :count).by(1)
    end

    it 'does not save anything if the transaction fails' do
      bad_auth = auth.dup
      bad_auth['credentials']['token'] = nil

      expect {
        Account.from_oauth(bad_auth)
      }.to raise_error(ActiveRecord::RecordInvalid)

      expect(Account.count).to eq(0)
      expect(User.count).to eq(0)
    end
  end
end

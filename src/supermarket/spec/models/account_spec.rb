require 'spec_helper'

describe Account do
  context 'associations' do
    it { should belong_to(:user) }
  end

  context 'validations' do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:uid) }
    it { should validate_presence_of(:provider) }
    it { should validate_presence_of(:oauth_token) }

    it 'validates the uniqueness of username scoped to provider with a custom error message' do
      create(:account, provider: 'github', username: 'johndoe')
      account = build(:account, provider: 'github', username: 'johndoe')
      account.save

      expect(account.errors.full_messages.to_s).to match(/The Github account \(johndoe\)/)
    end
  end

  context 'scopes' do
    describe 'for' do
      let(:github_account) { create(:account, provider: 'github') }
      let(:chef_account) { create(:account, provider: 'chef_oauth2') }

      it 'returns the first account with that username' do
        expect(Account.for('github')).to_not include(chef_account)
      end
    end

    describe 'with_username' do
      it 'returns the first account with that username' do
        account = create(:account, username: 'solidsnake')

        expect(Account.with_username('solidsnake').first!).to eql(account)
      end
    end

    describe 'tokens_expiring_soon' do
      it 'returns accounts whose oauth2 access token will expire soon' do
        nowish = Time.zone.now

        [-0.1, 0, 12.5, 25, 26.1].each do |expiry|
          create(:user).tap do |user|
            user.chef_account.update_attributes!(
              oauth_expires: nowish + expiry.minutes
            )
          end
        end

        expect(Account.tokens_expiring_soon(nowish).count).to eq(3)
      end
    end
  end
end

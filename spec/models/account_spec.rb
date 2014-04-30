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
    it { should validate_uniqueness_of(:provider).scoped_to(:username) }
  end

  context 'scopes' do
    describe 'for' do
      it 'returns the first account with that username' do
        github_account = create(:account, provider: 'github')
        chef_account = create(:account, provider: 'chef_oauth2')

        expect(Account.for('github')).to_not include(chef_account)
      end
    end

    describe 'with_username' do
      it 'returns the first account with that username' do
        account = create(:account, username: 'solidsnake')

        expect(Account.with_username('solidsnake').first!).to eql(account)
      end
    end
  end
end

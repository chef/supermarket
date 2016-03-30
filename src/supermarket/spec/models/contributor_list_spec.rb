require 'spec_helper'

describe ContributorList do
  context '#each' do
    it "yields a user, that user's chef account, and that user's github accounts" do
      user = create(:user)
      chef_account = user.accounts.for('chef_oauth2').first!
      github_account = create(:account, provider: 'github', user: user)

      contributor_list = ContributorList.new(User.where(id: user.id))

      expect do |b|
        contributor_list.each(&b)
      end.to yield_with_args(user, chef_account, [github_account])
    end

    it 'works even when there are no GitHub accounts created' do
      user = create(:user)
      chef_account = user.accounts.for('chef_oauth2').first!

      contributor_list = ContributorList.new(User.where(id: user.id))

      expect do |b|
        contributor_list.each(&b)
      end.to yield_with_args(user, chef_account, [])
    end

    it 'eager loads the accounts' do
      user = create(:user)
      create(:account, provider: 'github', user: user)

      chef_account = Account.for('chef_oauth2').where(user_id: user.id).first!
      github_account = Account.for('github').where(user_id: user.id).first!

      contributor_list = ContributorList.new(User.where(id: user.id))

      Account.where(id: [chef_account.id, github_account.id]).delete_all

      expect do |b|
        contributor_list.each(&b)
      end.to yield_with_args(user, chef_account, [github_account])
    end
  end
end

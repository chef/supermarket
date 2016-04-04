#
# A view model which backs the composite list of contributors and their
# associated accounts.
#
class ContributorList
  #
  # Initializes a new +ContributorList+, which finds all +Accounts+ for the
  # users.
  #
  # @param users - The users to initialize the +ContributorList+ with
  #
  #   ContributorList.new(User.all)
  #
  def initialize(users)
    @users = users
    accounts = Account.where(user_id: @users.map(&:id)).to_a.group_by(&:provider)
    @github_accounts = Array(accounts['github'])
    @chef_accounts = Array(accounts['chef_oauth2'])
  end

  #
  # Iterates through each +User+ in the +ContributorList+ and yields that
  # user's Chef account and all of its GitHub accounts.
  #
  # @yieldparam user [User]
  # @yieldparam chef_account [Account]
  # @yieldparam github_accounts [Array<Account>]
  #
  #   ContributorList.new(User.all).each do |user, chef_account, github_accounts|
  #     user.chef_account == chef_account
  #     user.accounts.for('github').to_a == github_accounts
  #   end
  #
  def each
    @users.each do |user|
      chef_account = @chef_accounts.find do |account|
        account.user_id == user.id
      end

      github_accounts = @github_accounts.select do |account|
        account.user_id == user.id
      end

      yield user, chef_account, github_accounts
    end
  end
end

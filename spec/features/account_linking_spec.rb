require 'spec_helper'

describe 'linking an OAuth account to a user' do
  it 'associates a user with a GitHub account' do
    sign_in(create(:user))
    manage_github_accounts

    connect_github_account

    expect_to_see_success_message
  end
end

describe 'unlinking an OAuth account on a user' do
  it 'unassociates a user with a GitHub account' do
    sign_in(create(:user))
    manage_github_accounts
    connect_github_account
    manage_github_accounts

    follow_relation 'disconnect_github'

    expect_to_see_success_message
  end
end

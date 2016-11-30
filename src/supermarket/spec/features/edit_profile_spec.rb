require 'spec_helper'

describe 'editing the current user profile' do
  it 'updates the users profile' do
    sign_in(create(:user))
    manage_profile

    within '.edit_user' do
      fill_in 'user_irc_nickname', with: 'eddardstark'
      fill_in 'user_company', with: 'Winterfell'
      fill_in 'user_jira_username', with: 'eddardstark'
      submit_form
    end

    expect_to_see_success_message
  end
end

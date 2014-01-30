require 'spec_feature_helper'

describe 'editing the current user profile' do
  it 'goes to the edit profile page' do
    sign_in(create(:user))
    click_link 'View Profile'
    click_link 'Edit Profile'
    fill_in 'user_email', with: 'eddardstark@agofai.com'
    fill_in 'user_first_name', with: 'Eddard'
    fill_in 'user_last_name', with: 'Stark'
    fill_in 'user_irc_nickname', with: 'eddardstark'
    fill_in 'user_company', with: 'Winterfell'
    fill_in 'user_jira_username', with: 'eddardstark'
    find_button('Update Profile').click
    expect_to_see_success_message
  end
end

require 'spec_feature_helper'

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

  it 'displays the pending requests for the user' do
    user = create(:user)
    create(:contributor_request, user: user)

    sign_in(user)
    manage_profile

    within '.pending-requests' do
      expect(page).to have_selector('.pending-request')
    end
  end
end

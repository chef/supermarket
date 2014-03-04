require 'spec_feature_helper'

describe 'changing the current user password' do
  it 'changes the current users password' do
    sign_in(create(:user))
    manage_profile
    follow_relation 'change_password'

    fill_in 'user_current_password', with: 'password'
    fill_in 'user_password', with: 'winter123'
    fill_in 'user_password_confirmation', with: 'winter123'
    submit_form

    expect_to_see_success_message
  end
end

require 'spec_feature_helper'

describe 'changing the current user password' do
  it 'changes the current users password' do
    sign_in(create(:user))
    click_link 'View Profile'
    click_link 'manage-profile'
    click_link 'manage-password'

    fill_in 'user_current_password', with: 'password'
    fill_in 'user_password', with: 'winter123'
    fill_in 'user_password_confirmation', with: 'winter123'

    find_button('Change Password').click

    expect(page).to have_selector('.alert-box.success')
  end
 end

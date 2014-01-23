require 'spec_feature_helper'

describe 'linking an OAuth account to a user' do
  it 'associates a user with a GitHub account' do
    sign_in(create(:user))
    click_link 'Profile'
    click_link 'Connect GitHub Account'
    expect(page).to have_content 'johndoe [GitHub]'
  end

  it 'associates a user with a Twitter account' do
    sign_in(create(:user))
    click_link 'Profile'
    click_link 'Connect Twitter Account'
    expect(page).to have_content 'johndoe [Twitter]'
  end
end

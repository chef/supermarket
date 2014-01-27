require 'spec_feature_helper'

describe 'linking an OAuth account to a user' do
  it 'associates a user with a GitHub account' do
    sign_in(create(:user))
    connect_account('GitHub')
    expect(page).to have_content 'johndoe [GitHub]'
  end

  it 'associates a user with a Twitter account' do
    sign_in(create(:user))
    connect_account('Twitter')
    expect(page).to have_content 'johndoe [Twitter]'
  end
end

describe 'unlinking an OAuth account on a user' do
  it 'unassociates a user with a GitHub account' do
    sign_in(create(:user))
    connect_account('GitHub')
    click_link 'Disconnect GitHub Account'
    expect(page).to_not have_content 'johndoe [GitHub]'
  end

  it 'unassociates a user with a Twitter account' do
    sign_in(create(:user))
    connect_account('Twitter')
    click_link 'Disconnect Twitter Account'
    expect(page).to_not have_content 'johndoe [Twitter]'
  end
end

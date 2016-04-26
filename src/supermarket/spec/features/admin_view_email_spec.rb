require 'spec_helper'

feature 'admin email permissions' do
  let(:user) { create(:user) }
  let(:admin) { create(:admin) }

  scenario 'admin user goes to another users page' do
    sign_in(admin)
    visit user_path(user)

    expect(page).to have_content(user.email)
  end

  scenario 'regular user goes to another users page' do
    sign_in(user)
    visit user_path(user)

    expect(page).to_not have_content(user.email)
  end

  scenario 'non-logged-in user goes to a users page' do
    visit user_path(user)

    expect(page).to_not have_content(user.email)
  end
end

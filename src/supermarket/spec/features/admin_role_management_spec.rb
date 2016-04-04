require 'spec_helper'

feature 'admin role management' do
  let(:user) { create(:user) }
  let(:admin) { create(:admin) }

  scenario 'admin user grants another user admin role' do
    sign_in(admin)
    visit user_path(user)
    follow_relation 'make_admin'

    expect_to_see_success_message
    expect(page).to have_content('Revoke Admin')
  end

  scenario 'admin revokes another admin user admin role' do
    sign_in(admin)
    visit user_path(user)
    follow_relation 'make_admin'
    follow_relation 'revoke_admin'

    expect_to_see_success_message
    expect(page).to have_content('Make Admin')
  end
end

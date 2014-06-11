require 'spec_feature_helper'

feature 'admin grants another user admin role' do
  let(:user) { create(:user) }
  let(:admin) { create(:admin) }

  before do
    sign_in(admin)
    visit user_path(user)
    follow_relation 'make_admin'
  end

  it 'displays a success message' do
    expect_to_see_success_message
  end

  it 'indicates that the user is now an admin' do
    expect(page).to have_content('Admin')
  end
end

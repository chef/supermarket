require 'spec_helper'

feature 'supermarket admins can feature a cookbook' do
  let(:cookbook) { create(:cookbook) }
  let(:admin) { create(:admin) }

  before do
    sign_in(admin)
    visit cookbook_path(cookbook)

    follow_relation 'toggle_featured'
  end

  it 'displays a success message' do
    expect_to_see_success_message
  end

  it 'indicates that the cookbook is now featured' do
    expect(page).to have_content('Unfeature')
  end
end

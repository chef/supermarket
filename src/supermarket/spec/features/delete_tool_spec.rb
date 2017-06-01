require 'spec_helper'

describe 'deleting a tool' do
  before do
    user = create(:user)
    create(:tool, name: 'butter', owner: user)

    sign_in(user)

    visit '/'
    follow_relation 'view_profile'
    follow_relation 'view_tools'
    follow_relation 'delete_tool'
  end

  it 'displays a success message' do
    expect_to_see_success_message
  end

  it 'deletes the tool' do
    within '.page' do
      expect(page).to have_no_content('butter')
    end
  end
end

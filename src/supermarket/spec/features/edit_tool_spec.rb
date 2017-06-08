require 'spec_helper'

describe 'editing a tool' do
  before do
    user = create(:user)
    create(:tool, name: 'butter', owner: user)

    sign_in(user)

    visit '/'
    follow_relation 'view_profile'
    follow_relation 'view_tools'
    follow_relation 'edit_tool'

    within '.edit_tool' do
      fill_in 'tool_name', with: 'margarine'

      submit_form
    end
  end

  it 'displays a success message' do
    expect_to_see_success_message
  end

  it 'updates the tool' do
    expect(page).to have_content('margarine')
  end
end

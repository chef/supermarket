require 'spec_helper'

describe 'creating a tool' do
  it 'is possible for users to create a tool' do
    sign_in(create(:user))

    visit '/'
    follow_relation 'view_profile'
    follow_relation 'view_tools'
    follow_relation 'add_tool'

    within '.new_tool' do
      fill_in 'tool_name', with: 'butter'
      fill_in 'tool_slug', with: 'butter'
      select 'Knife Plugin', from: 'Type'
      fill_in 'tool_description', with: 'Easily cut with knife'
      fill_in 'tool_source_url', with: 'http://example.com'
      fill_in 'tool_instructions', with: 'Delicious with toast.'

      submit_form
    end

    expect_to_see_success_message
  end
end

require 'spec_feature_helper'

feature 'cookbook owners can deprecate a cookbook' do
  let(:cookbook) { create(:cookbook) }
  let(:replacement_cookbook) { create(:cookbook) }
  let(:user) { cookbook.owner }

  before do
    sign_in(user)
    visit cookbook_path(cookbook)

    follow_relation 'deprecate'

    within '#deprecate' do
      find('#cookbook_replacement').set(replacement_cookbook.name)
      submit_form
    end
  end

  it 'displays a success message' do
    expect_to_see_success_message
  end

  it 'changes the link to the new cookbook' do
    expect(page).to have_content(replacement_cookbook.name)
  end
end

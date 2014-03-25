require 'spec_feature_helper'

describe "updating a cookbook's issue and source urls" do
  it 'displays success message when saved' do
    maintainer = create(:user)
    cookbook = create(:cookbook) # TODO: give this cookbook a real maintainer

    visit cookbook_path(cookbook)

    within '.cookbook-details' do
      follow_relation 'edit-cookbook-urls'
      fill_in 'Source URL', with: 'http://example.com/source'
      fill_in 'Issues URL', with: 'http://example.com/tissues'
      submit_form

      expect_to_see_success_message
    end
  end
end

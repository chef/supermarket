require 'spec_feature_helper'

describe 'viewing a cookbook' do
  it 'displays cookbook details if the cookbook exists' do
    maintainer = create(:user)
    cookbook = create(:cookbook) # TODO: give this cookbook a real maintainer

    visit cookbook_path(cookbook)

    expect(page).to have_selector('.cookbook')
  end
end

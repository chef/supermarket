require 'spec_feature_helper'

describe 'selecting cookbook install selection type' do
  it "persists the user's selected install type", use_poltergeist: true do
    sign_in(create(:user))
    cookbook = create(:cookbook)
    cookbook_two = create(:cookbook)

    visit cookbook_path(cookbook)

    within('.installs') do
      click_on 'Knife'
    end

    visit cookbook_path(cookbook_two)

    expect(page).to have_selector('#knife.active')
  end
end

require 'spec_feature_helper'

describe 'viewing a cookbook' do
  it 'displays cookbook details if the cookbook exists' do
    maintainer = create(:user)
    cookbook = create(:cookbook) # TODO: give this cookbook a real maintainer

    visit '/'
    follow_relation 'cookbooks'

    within '.recently-updated' do
      follow_relation 'cookbook'
    end

    expect(page).to have_selector('.cookbook_show')
  end

  it "shows that cookbook's versions" do
    maintainer = create(:user)
    cookbook = create(:cookbook) # TODO: give this cookbook a real maintainer

    visit cookbook_path(cookbook)

    follow_relation 'cookbook_versions'
    relations('cookbook_version').first.click

    expect(page).to have_selector('.cookbook_show')
  end

  it "shows that cookbook's dependencies" do
    maintainer = create(:user)
    cookbook = create(:cookbook) # TODO: give this cookbook a real maintainer
    apt = create(:cookbook, name: 'apt')

    create(:cookbook_dependency, cookbook_version: cookbook.cookbook_versions.first, cookbook: apt)

    visit cookbook_path(cookbook)

    follow_relation 'cookbook_dependencies'
    relations('cookbook_dependency').first.click

    expect(page).to have_selector('.cookbook_show')
    expect(page).to have_content('apt')
  end
end

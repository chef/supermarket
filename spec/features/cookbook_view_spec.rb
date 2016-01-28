require 'spec_helper'

describe 'viewing a cookbook' do
  it 'displays cookbook details if the cookbook exists' do
    owner = create(:user)
    cookbook = create(:cookbook, owner: owner)

    visit '/'
    follow_relation 'cookbooks'

    within '.recently-updated' do
      follow_relation 'cookbook'
    end

    expect(page).to have_selector('.cookbook_show')
  end

  it "shows that cookbook's versions" do
    owner = create(:user)
    cookbook = create(:cookbook, owner: owner)

    visit cookbook_path(cookbook)

    follow_relation 'cookbook_versions'
    relations('cookbook_version').first.click

    expect(page).to have_selector('.cookbook_show')
  end

  it "shows that cookbook's dependencies" do
    owner = create(:user)
    cookbook = create(:cookbook, owner: owner)
    apt = create(:cookbook, name: 'apt', owner: owner)

    create(
      :cookbook_dependency,
      cookbook_version: cookbook.latest_cookbook_version,
      cookbook: apt
    )

    visit cookbook_path(cookbook)

    follow_relation 'cookbook_dependencies'
    relations('cookbook_dependency').first.click

    expect(page).to have_selector('.cookbook_show')
    expect(page).to have_content('apt')
  end
end

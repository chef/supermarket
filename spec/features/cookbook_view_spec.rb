require 'spec_helper'

describe 'viewing a cookbook' do
  let!(:owner) { create(:user) }
  let!(:cookbook) { create(:cookbook, owner: owner) }

  it 'displays cookbook details if the cookbook exists' do
    visit '/'
    follow_relation 'cookbooks'

    within '.recently-updated' do
      follow_relation 'cookbook'
    end

    expect(page).to have_selector('.cookbook_show')
  end

  it "shows that cookbook's versions" do
    visit cookbook_path(cookbook)

    follow_relation 'cookbook_versions'
    relations('cookbook_version').first.click

    expect(page).to have_selector('.cookbook_show')
  end

  describe 'dependencies' do
    let(:apt) { create(:cookbook, name: 'apt', owner: owner) }
    let(:yum) { create(:cookbook, name: 'yum', owner: owner) }

    before :each do
      create(
        :cookbook_dependency,
        cookbook_version: cookbook.latest_cookbook_version,
        cookbook: apt
      )
      create(
        :cookbook_dependency,
        cookbook_version: cookbook.cookbook_versions.first,
        cookbook: yum
      )
    end

    it "shows that cookbook's latest version's dependencies" do
      visit cookbook_path(cookbook)

      follow_relation 'cookbook_dependencies'
      relations('cookbook_dependency').first.click

      expect(page).to have_selector('.cookbook_show')
      expect(page).to have_content('apt')
    end

    it "shows that cookbook's previous version's dependencies" do
      visit cookbook_version_path(cookbook_id: cookbook, version: cookbook.cookbook_versions.first)

      follow_relation 'cookbook_dependencies'
      relations('cookbook_dependency').first.click

      expect(page).to have_selector('.cookbook_show')
      expect(page).to have_content('yum')
    end
  end
end

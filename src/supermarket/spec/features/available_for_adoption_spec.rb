require 'spec_helper'

describe 'adoptable cookbooks directory' do
  # let!(:adoptable_cookbook) { create(:cookbook, up_for_adoption: true ) }

  before do
    @adoptable_cookbook = create(:cookbook, name: 'CookbookName', up_for_adoption: true)

    visit '/available_for_adoption'

    click_link @adoptable_cookbook.name
  end

  it 'shows an adoptable cookbook' do
    expect(page).to have_content(@adoptable_cookbook.name)
  end
end

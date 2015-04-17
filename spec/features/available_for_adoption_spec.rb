require 'spec_helper'

describe 'adoptable cookbooks directory' do

  # let!(:adoptable_cookbook) { create(:cookbook, up_for_adoption: true ) }

  before do
    # create_list(:cookbook, 5)
    @adoptable_cookbook = create(:cookbook, name: 'CookbookName', up_for_adoption: true )
    puts @adoptable_cookbook.name

    visit '/available_for_adoption'

    within '.adoptable_cookbooks_list' do
      click_link "#{@adoptable_cookbook.name}"
      save_and_open_page
    end
  end

  it 'shows an adoptable cookbook' do
    # within '.' do
      expect(page).to have_content(@adoptable_cookbook.name)
    # end
  end
end

require 'spec_feature_helper'

describe 'cookbook feed' do
  it 'lists cookbooks sorted in a particular order' do
    visit '/'
    click_link 'Cookbooks'

    within '.recently-updated' do
      click_link 'View All'
    end

    expect(all('.order_cookbooks_by .active').size).to eql(1)
  end

  it 'lists cookbooks by a metadata search term' do
    create(:cookbook, name: 'AmazingCookbook')

    visit '/'
    click_link 'Cookbooks'

    within '.cookbook_search' do
      fill_in 'q', with: 'Amazing'
      submit_form
    end

    expect(all('.cookbook').size).to eql(1)
  end
end

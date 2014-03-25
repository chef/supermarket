require 'spec_feature_helper'

describe 'cookbook feed' do
  it 'lists cookbooks sorted in a particular order' do
    visit '/'
    click_link 'Cookbooks'

    within '.recently-updated' do
      click_link 'View All'
    end

    expect(all('.order .active').size).to eql(1)
  end

  it 'lists cookbooks by category' do
    create_list(:cookbook, 5, category: create(:category, name: 'Databases'))
    create_list(:cookbook, 5, category: create(:category, name: 'Other'))

    visit '/'
    click_link 'Cookbooks'

    within '.categories' do
      click_link 'Other'
    end

    expect(all('.categories .active').size).to eql(1)
    expect(all('.cookbook').size).to eql(5)
  end

  it 'lists cookbooks by a metadata search term' do
    create(:cookbook, name: 'Amazing Cookbook')

    visit '/'
    click_link 'Cookbooks'

    within '.page' do
      fill_in 'q', with: 'Amazing'
      submit_form
    end

    expect(all('.cookbook').size).to eql(1)
  end
end

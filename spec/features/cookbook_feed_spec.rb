require 'spec_helper'

describe 'cookbook feed' do
  it 'lists cookbooks by a metadata search term' do
    create(:cookbook, name: 'AmazingCookbook')

    visit '/'

    within '.appnav' do
      click_link 'Cookbooks'
    end

    within '.search_form' do
      fill_in 'q', with: 'Amazing'
      submit_form
    end

    expect(all('.listing').size).to eql(1)
  end
end

require 'spec_feature_helper'

describe 'cookbook feed' do
  before { create_list(:cookbook, 10) }

  it 'lists cookbooks sorted in a particular order' do
    visit '/'
    click_link 'Cookbooks'

    within '.recently-updated' do
      click_link 'View All'
    end

    expect(all('.cookbook').size).to eql(10)

    within '.order' do
      expect(all('.active').size).to eql(1)
    end
  end
end

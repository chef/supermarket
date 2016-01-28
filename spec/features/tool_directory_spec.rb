require 'spec_helper'

describe 'tool directory' do
  before do
    create_list(:tool, 5)

    visit '/'

    within '.appnav' do
      click_link 'Tools & Plugins'
    end
  end

  it 'lists the five most recently added tools' do
    within '.recently_added_tools' do
      expect(all('.simple_listing li').size).to eql(5)
    end
  end
end

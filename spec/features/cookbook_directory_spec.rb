require 'spec_feature_helper'

describe 'cookbook directory' do
  before do
    create_list(:cookbook, 5)

    visit '/'

    within '.appnav' do
      click_link 'Cookbooks'
    end
  end

  it 'lists the five most recently updated cookbooks' do
    within '.recently-updated' do
      expect(all('.simple_listing li').size).to eql(5)
    end
  end

  it 'lists the five most downloaded cookbooks' do
    within '.most-downloaded' do
      expect(all('.simple_listing li').size).to eql(5)
    end
  end

  it 'lists the five most followed cookbooks' do
    within '.most-followed' do
      expect(all('.simple_listing li').size).to eql(5)
    end
  end
end

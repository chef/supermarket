require 'spec_feature_helper'

describe 'cookbook directory' do
  before do
    create_list(:cookbook, 5)

    visit '/'
    click_link 'Cookbooks'
  end

  it 'lists the three most recently updated cookbooks' do
    within '.recently-updated' do
      expect(all('.simple_cookbook').size).to eql(5)
    end
  end

  it 'lists the three most downloaded cookbooks' do
    within '.most-downloaded' do
      expect(all('.simple_cookbook').size).to eql(5)
    end
  end

  it 'lists the three most followed cookbooks' do
    within '.most-followed' do
      expect(all('.simple_cookbook').size).to eql(5)
    end
  end
end

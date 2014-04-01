require 'spec_feature_helper'

describe 'cookbook directory' do
  before do
    create_list(:cookbook, 3)

    visit '/'
    click_link 'Cookbooks'
  end

  it 'lists the three most recently updated cookbooks' do
    within '.recently-updated' do
      expect(all('.cookbook').size).to eql(3)
    end
  end

  it 'lists the three most recently created cookbooks' do
    within '.recently-added' do
      expect(all('.cookbook').size).to eql(3)
    end
  end

  it 'lists the three most downloaded cookbooks' do
    within '.most-downloaded' do
      expect(all('.cookbook').size).to eql(3)
    end
  end

  it 'lists the three most followed cookbooks' do
    within '.most-followed' do
      expect(all('.cookbook').size).to eql(3)
    end
  end
end

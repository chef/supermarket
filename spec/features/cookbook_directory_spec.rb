require 'spec_feature_helper'

describe 'cookbook directory' do
  it 'lists the three most recently updated cookbooks' do
    create_list(:cookbook, 3, updated_at: 1.day.ago)

    visit '/'
    click_link 'Cookbooks'

    within '.recently-updated' do
      expect(all('.cookbook').size).to eql(3)
    end
  end

  it 'lists the three most recently created cookbooks' do
    create_list(:cookbook, 3, created_at: 1.day.ago)

    visit '/'
    click_link 'Cookbooks'

    within '.recently-added' do
      expect(all('.cookbook').size).to eql(3)
    end
  end
end

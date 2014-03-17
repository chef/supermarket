require 'spec_feature_helper'

describe 'cookbook directory' do
  it 'lists the three most recently updated cookbooks' do
    visit '/'
    click_link 'Cookbooks'

    within '.recently-updated' do
      expect(all('.cookbook').size).to eql(3)
      expect(Date.parse(first('.updated-at').text) > 30.days.ago).to be_true
    end
  end

  it 'lists the three most recently created cookbooks'
end

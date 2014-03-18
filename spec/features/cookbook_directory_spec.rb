require 'spec_feature_helper'

describe 'cookbook directory' do
  context 'there are cookbooks that have recently been updated' do
    before { create_list(:cookbook, 3, updated_at: 1.day.ago) }

    it 'lists the three most recently updated cookbooks' do
      visit '/'
      click_link 'Cookbooks'

      within '.recently-updated' do
        expect(all('.cookbook').size).to eql(3)
      end
    end
  end

  context 'there are cookbooks that have recently been created' do
    before { create_list(:cookbook, 3, created_at: 1.day.ago) }

    it 'lists the three most recently created cookbooks' do
      visit '/'
      click_link 'Cookbooks'

      within '.recently-created' do
        expect(all('.cookbook').size).to eql(3)
      end
    end
  end
end

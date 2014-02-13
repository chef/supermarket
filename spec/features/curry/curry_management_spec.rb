require 'spec_feature_helper'

describe 'Curry management' do

  describe 'when a Chef Admin adds a GitHub repository to the Super Market watched repositories' do
    it 'subscribes to a repository' do
      sign_in(create(:admin))
      find('.admin.repositories').click
      fill_in 'GitHub Repository Owner', with: 'cramerdev'
      fill_in 'GitHub Repository Name', with: 'paprika'
      click_on 'Add Repository'
      expect(page).to have_selector '.repository'
    end
  end

  describe 'when a Chef Admin deletes a repository' do
    it 'subscribes to a repository' do
      sign_in(create(:admin))
      find('.admin.repositories').click
      fill_in 'GitHub Repository Owner', with: 'cramerdev'
      fill_in 'GitHub Repository Name', with: 'paprika'
      click_on 'Add Repository'
      click_on 'Remove Repository'
      expect(page).to_not have_selector '.repository'
    end
  end

end

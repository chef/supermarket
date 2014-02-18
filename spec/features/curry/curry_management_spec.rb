require 'spec_feature_helper'

describe 'Curry management' do

  describe 'when a Chef Admin adds a GitHub repository to the Super Market watched repositories' do
    it 'subscribes to a repository' do
      sign_in(create(:admin))

      manage_repositories

      fill_in 'GitHub Repository Owner', with: 'cramerdev'
      fill_in 'GitHub Repository Name', with: 'paprika'
      submit_form

      expect(page).to have_selector '.repository'
    end
  end

  describe 'when a Chef Admin deletes a repository' do
    it 'subscribes to a repository' do
      sign_in(create(:admin))

      manage_repositories

      fill_in 'GitHub Repository Owner', with: 'cramerdev'
      fill_in 'GitHub Repository Name', with: 'paprika'
      submit_form

      follow_relation 'remove_repository'

      expect(page).to_not have_selector '.repository'
    end
  end

end

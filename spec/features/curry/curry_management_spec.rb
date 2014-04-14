require 'spec_feature_helper'

describe 'Curry management', uses_secrets: true do
  describe 'when a Chef Admin adds a GitHub repository to the Super Market watched repositories' do
    it 'subscribes to a repository' do
      sign_in(create(:admin))

      manage_repositories

      within '.new_curry_repository' do
        fill_in 'GitHub Repository Owner', with: 'gofullstack'
        fill_in 'GitHub Repository Name', with: 'paprika'
        submit_form
      end

      expect_to_see_success_message
    end
  end

  describe 'when a Chef Admin deletes a repository' do
    it 'subscribes to a repository' do
      sign_in(create(:admin))

      manage_repositories

      within '.new_curry_repository' do
        fill_in 'GitHub Repository Owner', with: 'gofullstack'
        fill_in 'GitHub Repository Name', with: 'paprika'
        submit_form
      end

      follow_relation 'remove_repository'

      expect_to_see_success_message
    end
  end
end

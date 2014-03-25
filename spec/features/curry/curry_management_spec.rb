require 'spec_feature_helper'

describe 'Curry management', skip_travis: true do
  describe 'when a Chef Admin adds a GitHub repository to the Super Market watched repositories' do
    it 'subscribes to a repository' do
      sign_in(create(:admin))

      manage_repositories

      fill_in 'GitHub Repository Owner', with: 'gofullstack'
      fill_in 'GitHub Repository Name', with: 'paprika'
      submit_form

      expect_to_see_success_message
    end
  end

  describe 'when a Chef Admin deletes a repository' do
    it 'subscribes to a repository' do
      sign_in(create(:admin))

      manage_repositories

      fill_in 'GitHub Repository Owner', with: 'gofullstack'
      fill_in 'GitHub Repository Name', with: 'paprika'
      submit_form

      follow_relation 'remove_repository'

      expect_to_see_success_message
    end
  end
end

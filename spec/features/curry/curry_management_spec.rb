require 'spec_helper'
require 'vcr_helper'

describe 'Curry management', uses_secrets: true do
  describe 'when a Chef Admin adds a GitHub repository to the Super Market watched repositories' do
    it 'subscribes to a repository' do
      sign_in(create(:admin))

      manage_repositories

      within '.new_curry_repository' do
        fill_in 'curry_repository_full_name', with: 'gofullstack/paprika'

        VCR.use_cassette('curry_add_repo', record: :once) do
          submit_form
        end
      end

      expect_to_see_success_message
    end
  end

  describe 'when a Chef Admin deletes a repository' do
    it 'subscribes to a repository' do
      sign_in(create(:admin))

      manage_repositories

      within '.new_curry_repository' do
        fill_in 'curry_repository_full_name', with: 'gofullstack/paprika'

        VCR.use_cassette('curry_add_repo', record: :once) do
          submit_form
        end
      end

      VCR.use_cassette('curry_remove_repo', record: :once) do
        follow_first_relation 'remove_repository'
      end

      expect_to_see_success_message
    end
  end

  describe 'when a Chef Admin evaluates a repository' do
    it 'shows success' do
      sign_in(create(:admin))

      manage_repositories

      within '.new_curry_repository' do
        fill_in 'curry_repository_full_name', with: 'gofullstack/paprika'

        VCR.use_cassette('curry_add_repo', record: :once) do
          submit_form
        end
      end

      follow_first_relation 'evaluate_repository'

      expect_to_see_success_message
    end
  end
end

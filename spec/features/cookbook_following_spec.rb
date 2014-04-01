require 'spec_feature_helper'

describe 'cookbook following' do
  shared_examples 'a page which has a Follow button' do
    it 'allows a user to follow a cookbook' do
      follow_relation 'follow'

      expect(page).to have_xpath("//a[starts-with(@rel, 'unfollow')]")
    end

    it 'allows a user to unfollow a cookbook' do
      follow_relation 'follow'
      follow_relation 'unfollow'

      expect(page).to have_xpath("//a[starts-with(@rel, 'follow')]")
    end
  end

  shared_examples 'a page which can manage cookbook URLs' do
    it 'displays success message when saved' do
      within '.cookbook-details' do
        follow_relation 'edit-cookbook-urls'
        fill_in 'Source URL', with: 'http://example.com/source'
        fill_in 'Issues URL', with: 'http://example.com/tissues'
        submit_form
      end

      expect_to_see_success_message
    end

    it 'displays a failure message when invalid urls are entered' do
      within '.cookbook-details' do
        follow_relation 'edit-cookbook-urls'
        fill_in 'Source URL', with: 'example'
        fill_in 'Issues URL', with: 'example'

        expect(page).to have_selector('.error')
      end
    end
  end

  context 'when navigating from the cookbooks directory' do
    before do
      sign_in(create(:user))
      create(:cookbook) # TODO: give this cookbook a real maintainer

      visit '/'
      follow_relation 'cookbooks'

      within '.recently-updated' do
        follow_relation 'cookbook'
      end
    end

    it_behaves_like 'a page which has a Follow button'
    it_behaves_like 'a page which can manage cookbook URLs'
  end

  context 'when navigating from the feed of recently updated cookbooks' do
    before do
      sign_in(create(:user))
      create(:cookbook) # TODO: give this cookbook a real maintainer

      visit '/'
      click_link 'Cookbooks'

      within '.recently-updated' do
        click_link 'View All'
      end

      within '.cookbook_listing' do
        relations('cookbook').first.click
      end
    end

    it_behaves_like 'a page which has a Follow button'
    it_behaves_like 'a page which can manage cookbook URLs'
  end

  context 'when navigating from a Category' do
    before do
      sign_in(create(:user))
      cookbook = create(:cookbook) # TODO: give this cookbook a real maintainer

      visit '/'
      click_link 'Cookbooks'

      within '.categories' do
        click_link cookbook.category.name
      end

      within '.cookbook_listing' do
        relations('cookbook').first.click
      end
    end

    it_behaves_like 'a page which has a Follow button'
    it_behaves_like 'a page which can manage cookbook URLs'
  end

  context 'when navigating from search results', focus: true do
    before do
      sign_in(create(:user))
      create(:cookbook, name: 'AmazingCookbook')

      visit '/'
      click_link 'Cookbooks'

      within '.page' do
        fill_in 'q', with: 'Amazing'
        submit_form
      end

      within '.cookbook_listing' do
        relations('cookbook').first.click
      end
    end

    it_behaves_like 'a page which has a Follow button'
    it_behaves_like 'a page which can manage cookbook URLs'
  end
end

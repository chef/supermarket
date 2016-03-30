require 'spec_helper'

describe 'A cookbook that has been granted a Partner badge' do
  let!(:badged_cookbook) { create(:partner_cookbook, name: 'ReallyGreatPartnerCookbook') }
  let!(:other_badged_cookbook) { create :partner_cookbook }
  let!(:non_badged_cookbook) { create :cookbook }

  describe 'on its page' do
    before do
      visit cookbook_path(badged_cookbook)
    end

    it 'shows a Badges section in the sidebar' do
      expect(find('div.sidebar')).to have_content('Badges')
    end

    it 'shows a partner badge' do
      expect(find('.cookbook_badges')).to have_css('img#partner_badge')
    end
  end

  describe 'in the search results of cookbooks' do
    before do
      visit '/'
    end

    it 'shows a partner badge' do
      within '.search_bar' do
        follow_relation 'toggle-search-types'
        follow_relation 'toggle-cookbook-search'
        fill_in 'q', with: badged_cookbook.name
        submit_form
      end

      expect(page).to have_content(badged_cookbook.name)
      expect(find('.cookbook_badges')).to have_css('img#partner_badge')
    end

    it 'shows only partner-badged cookbooks when selected' do
      within '.search_form' do
        check 'badges_partner'
        submit_form
      end

      expect(page).to have_content(badged_cookbook.name)
      expect(page).to have_content(other_badged_cookbook.name)
      expect(page).not_to have_content(non_badged_cookbook.name)
    end
  end
end

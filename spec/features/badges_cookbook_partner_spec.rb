require 'spec_helper'

describe 'A cookbook that has been granted a Partner badge' do
  let(:badged_cookbook) { create(:partner_cookbook, name: 'ReallyGreatPartnerCookbook') }

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
  end
end

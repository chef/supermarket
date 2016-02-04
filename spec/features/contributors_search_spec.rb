require 'spec_helper'

feature 'collaborators search' do
  let(:suzie) { create(:user, first_name: 'Sally', last_name: 'Sue', email: 'sallysue@chef.io') }
  let(:suzie_contributor) { create(:contributor, user: suzie) }

  let(:billy) { create(:user, first_name: 'Billy', last_name: 'Bob', email: 'billybob@chef.io') }
  let(:billy_contributor) { create(:contributor, user: billy) }

  before do
    # Create ICLA
    create(:icla)

    # Sign ICLA as Suzie
    sign_in(suzie)
    sign_icla
    sign_out

    # Sign ICLA as Billy
    sign_in(billy)
    sign_icla
    sign_out

    visit contributors_path
  end

  describe 'user visits the contributors page' do
    before do
      expect(User.authorized_contributors).to include(suzie)
    end

    it 'shows a search field' do
      expect(page).to have_field('Search')
    end

    it 'shows a search button' do
      expect(page).to have_button('Search Contributors')
    end

    describe 'user searches for a contributor' do
      before do
        fill_in('Search', with: suzie.username)
        click_button('Search Contributors')
      end

      it 'shows the contributor the user searched for' do
        expect(page).to have_content(suzie.username)
      end
    end
  end
end

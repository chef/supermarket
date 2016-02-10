require 'spec_helper'

feature 'collaborators search' do
  let(:suzie) { create(:user, first_name: 'Sally', last_name: 'Sue', email: 'sallysue@chef.io') }
  let(:suzie_contributor) { create(:contributor, user: suzie) }

  let(:billy) { create(:user, first_name: 'Billy', last_name: 'Bob', email: 'billybob@chef.io') }
  let(:billy_contributor) { create(:contributor, user: billy) }

  before do
    # Making usernames distinct
    suzie.chef_account.update_attributes!(
      username: 'suzie',
      uid: 'suzie'
    )

    billy.chef_account.update_attributes!(
      username: 'billy',
      uid: 'billy'
    )

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
      expect(page).to have_field('contributors_q')
    end

    it 'shows a search button' do
      expect(page).to have_button('Search')
    end

    it 'shows the contributors' do
      expect(page).to have_content(suzie.username)
      expect(page).to have_content(billy.username)
    end

    describe 'user searches for a contributor' do
      before do
        within '.contributor_search' do
          fill_in('contributors_q', with: 'suzie')
          submit_form
        end
      end

      it 'shows the contributor the user searched for' do
        expect(page).to have_content(suzie.username)
        expect(page).to_not have_content(billy.username)
      end
    end
  end

  describe 'user clicks on the Individuals tab' do
    let(:gary) { create(:user, first_name: 'Gary', last_name: 'Indiana', email: 'garyindiana@chef.io') }

    before do
      gary.chef_account.update_attributes!(
        username: 'gary',
        uid: 'gary'
      )

      expect(gary.signed_icla?).to eq(false)

      click_link('Individuals')
    end

    it 'shows ICLA signers' do
      expect(page).to have_content(suzie.username)
      expect(page).to have_content(billy.username)
      expect(page).to_not have_content(gary.username)
    end

    describe 'user searches for an ICLA signer' do
      before do
        # overwriting values of the icla factory to make distinct
        suzie.icla_signatures.first.update_attributes!(
          first_name: 'Sally',
          last_name: 'Sue',
          email: 'sallysue@chef.io'
        )

        billy.icla_signatures.first.update_attributes!(
          first_name: 'Billy',
          last_name: 'Bob',
          email: 'billybob@chef.io'
        )

        within '.contributor_search' do
          fill_in('contributors_q', with: 'Sally')
          submit_form
        end
      end

      it 'shows the contributor the user searched for' do
        expect(page).to have_content(suzie.first_name)
        expect(page).to_not have_content(billy.first_name)
      end
    end
  end

  describe 'user clicks on the Companies tab' do
    let!(:org1) { create(:organization) }
    let!(:org2) { create(:organization) }
    let!(:ccla_signature1) { create(:ccla_signature, organization: org1, company: 'International House of Pancakes') }
    let!(:ccla_signature2) { create(:ccla_signature, organization: org2, company: "Bob's Fish Shack") }

    before do
      click_link('Companies')
    end

    it 'shows the CCLA companies' do
      expect(page).to have_content(ccla_signature1.company)
      expect(page).to have_content(ccla_signature2.company)
    end

    describe 'user searchs for a company' do
      before do
        within '.contributor_search' do
          fill_in('contributors_q', with: ccla_signature1.company)
          submit_form
        end
      end

      it 'shows the company the user searches for' do
        expect(page).to have_content(ccla_signature1.company)
        expect(page).to_not have_content(ccla_signature2.company)
      end
    end
  end
end

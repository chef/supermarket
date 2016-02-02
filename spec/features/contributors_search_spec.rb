require 'spec_helper'

feature 'collaborators search' do
  let(:suzie) { create(:user, first_name: 'Sally', last_name: 'Sue', email: 'sallysue@chef.io') }
  let(:billy) { create(:user, first_name: 'Billy', last_name: 'Bob', email: 'billybob@chef.io') }

  before do
    visit contributors_path
  end

  describe 'user visits the contributors page' do
    it 'shows a search field'

    describe 'user searches for a contributor' do
      it 'shows the contributor the user searched for'

      it 'does not show a contributor the user did not search for'
    end
  end
end

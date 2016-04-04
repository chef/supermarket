require 'spec_helper'

describe 'viewing contributors' do
  context 'all contributors' do
    it 'lists all folks authorized to contribute' do
      create(:ccla_signature, organization: create(:organization, ccla_signatures_count: 0))
      create(:icla_signature)

      visit '/'
      follow_relation 'contributors'

      expect(all('.contributor').size > 0).to be true
    end
  end

  context 'individual contributors' do
    it 'lists all folks who have signed the ICLA' do
      create(:icla_signature)

      visit '/'
      follow_relation 'contributors'
      follow_relation 'individual-contributors'

      expect(all('.contributor').size > 0).to be true
    end
  end

  context 'companies' do
    context "viewing a company's contributors" do
      it 'lists all contributors on behalf of that company' do
        create(:organization, contributors: [create(:contributor)])

        visit '/'
        follow_relation 'contributors'
        follow_relation 'companies'

        within 'tbody tr:last-child' do
          follow_relation 'company-contributors'
        end

        expect(all('.contributor').size > 0).to be true
      end
    end
  end

  context 'the sidebar' do
    it 'lists all the repositories Supermarket is subscribed to' do
      create(:repository)

      visit '/'
      follow_relation 'contributors'

      expect(all('.repository').size > 0).to be true
    end

    it "lists user's agreements when signed in" do
      icla_signature = create(:icla_signature)
      user = icla_signature.user
      create(:contributor, user: user)

      sign_in(user)

      visit '/'
      follow_relation 'contributors'

      within '.sidebar' do
        expect(relations('icla-signature').size > 0).to be true
        expect(relations('ccla-membership').size > 0).to be true
      end
    end
  end
end

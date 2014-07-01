require 'spec_feature_helper'

describe 'viewing contributors' do
  context 'all contributors' do
    it 'lists all folks authorized to contribute' do
      create(:ccla_signature, organization: create(:organization, ccla_signatures_count: 0))
      create(:icla_signature)

      visit '/'
      follow_relation 'contributors'

      expect(all('.contributor').size > 0).to be_true
    end
  end

  context 'individual contributors' do
    it 'lists all folks who have signed the ICLA' do
      create(:ccla_signature)
      create(:icla_signature)

      visit '/'
      follow_relation 'contributors'
      follow_relation 'individual-contributors'

      expect(all('.contributor').size > 0).to be_true
    end
  end

  context 'companies' do
    before do
      create(:ccla_signature)
      create(:icla_signature)
    end

    it 'lists all companies who have signed the CCLA' do
      visit '/'
      follow_relation 'contributors'
      follow_relation 'company-contributors'

      expect(all('.company').size).to eql(1)
    end

    context "viewing a company's contributors" do
      it 'lists all contributors on behalf of that company' do
        visit '/'
        follow_relation 'contributors'
        follow_relation 'companies'

        within 'tbody tr:first-child' do
          follow_relation 'company-contributors'
        end

        expect(all('.contributors').size > 0).to be_true
      end
    end
  end

  context 'the sidebar' do
  end
end

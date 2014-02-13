require 'spec_helper'

describe Organization do
  context 'associations' do
    it { should have_many(:contributors) }
    it { should have_many(:users) }
    it { should have_many(:invitations) }
    it { should have_many(:ccla_signatures) }
  end

  describe '#admins' do
    it 'returns admin contributors' do
      contributor = create(:contributor, admin: true)
      organization = create(:organization, contributors: [contributor])

      expect(organization.admins).to include(contributor)
    end
  end

  describe '#latest_ccla_signature' do
    it 'returns the latest ccla signature based on date signed' do
      organization = create(:organization)
      one_year_ago = create(:ccla_signature, signed_at: 1.year.ago, organization: organization)
      one_month_ago = create(:ccla_signature, signed_at: 1.month.ago, organization: organization)

      expect(organization.latest_ccla_signature).to eql(one_month_ago)
    end
  end
end

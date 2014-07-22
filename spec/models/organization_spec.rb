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

  describe '#combine!' do
    let!(:ccla) { create(:ccla) }
    let!(:org1) { create(:organization) }
    let!(:org2) { create(:organization) }
    let!(:sally) { create(:user) }
    let!(:hank) { create(:user) }
    let!(:ccla_signature1) { create(:ccla_signature, ccla: ccla, user: sally, organization: org1) }
    let!(:ccla_signature2) { create(:ccla_signature, ccla: ccla, user: hank, organization: org2) }
    let!(:contributor1) { create(:contributor, organization: org1, user: sally) }
    let!(:contributor2) { create(:contributor, organization: org2, user: hank) }
    let!(:invitation1) { create(:invitation, organization: org1) }
    let!(:invitation2) { create(:invitation, organization: org2) }

    after do
      expect do
        Organization.find org2.id
      end.to raise_exception(ActiveRecord::RecordNotFound)
    end

    it 'should transfer CCLA signatures to the new organization' do
      expect(org1.ccla_signatures).to include(ccla_signature1)
      org1.combine!(org2)
      org1.reload
      expect(org1.ccla_signatures).to include(ccla_signature1, ccla_signature2)
    end

    it 'should transfer contributors to the new organization' do
      expect(org1.contributors).to include(contributor1)
      org1.combine!(org2)
      org1.reload
      expect(org1.contributors).to include(contributor1, contributor2)
    end

    it 'should transfer invitations to the new organization' do
      expect(org1.invitations).to include(invitation1)
      org1.combine!(org2)
      org1.reload
      expect(org1.invitations).to include(invitation1, invitation2)
    end

    it 'should not allow duplicate contributors' do
      jimmy = create(:user)
      create(:contributor, organization: org1, user: jimmy)
      create(:contributor, organization: org2, user: jimmy)
      org1.combine!(org2)
      org1.reload
      how_many_jimmys = org1.contributors.select { |c| c.user.id == jimmy.id }.size
      expect(how_many_jimmys).to eql(1)
    end

    it 'should strip admin privileges on incoming contributors' do
      jimmy = create(:user)
      create(:contributor, organization: org2, user: jimmy, admin: true)
      org1.combine!(org2)
      org1.reload
      jimmeh = org1.contributors.where(user_id: jimmy.id).first
      expect(jimmeh.admin).to be_false
    end
  end

  describe '#pending_requests_to_join' do
    it 'returns the contributor requests for that organization that are pending' do
      organization = create(:organization)
      pending_request = create(
        :contributor_request,
        organization: organization
      )

      accepted_request = create(
        :contributor_request,
        organization: organization
      )
      accepted_request.accept

      requests = organization.pending_requests_to_join

      expect(requests).to include(pending_request)
      expect(requests).to_not include(accepted_request)
    end
  end
end

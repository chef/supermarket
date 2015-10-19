require 'spec_helper'

describe CclaSignature do
  context 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:ccla) }
    it { should belong_to(:organization) }
  end

  context 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:phone) }
    it { should validate_presence_of(:company) }
    it { should validate_presence_of(:address_line_1) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:state) }
    it { should validate_presence_of(:zip) }
    it { should validate_presence_of(:country) }
    it { should validate_acceptance_of(:agreement) }
  end

  it_behaves_like 'exportable'

  describe '#sign!' do
    let(:ccla_signature) { build(:ccla_signature) }
    before { ccla_signature.sign! }

    it 'creates an associated organization' do
      expect(ccla_signature.organization).to_not be_nil
    end

    it 'creates a contributor for the associated organization' do
      expect(ccla_signature.organization.contributors.count).to eql(1)
    end

    it 'saves the ccla signature' do
      expect(ccla_signature.persisted?).to be true
    end
  end

  describe '.by_organization' do
    context 'when multiple organizations have signed a CCLA' do
      let(:old_org) { create(:organization, ccla_signatures_count: 0) }
      let(:recent_org) { create(:organization, ccla_signatures_count: 0) }
      let!(:recent_org_signature) { create(:ccla_signature, organization: recent_org, signed_at: 1.day.ago) }
      let!(:old_org_signature) { create(:ccla_signature, organization: old_org, signed_at: 1.year.ago) }

      it 'should return the signatures' do
        expect(CclaSignature.by_organization.count).to eql(2)
      end

      it 'should order the signatures ascending by signed at date' do
        expect(CclaSignature.by_organization.first).to eql(old_org_signature)
      end
    end

    context 'when a organization has re-signed a CCLA' do
      let(:organization) { create(:organization, ccla_signatures_count: 0) }
      let!(:recent_signature) { create(:ccla_signature, organization: organization, signed_at: 1.month.ago) }
      let!(:old_signature) { create(:ccla_signature, organization: organization, signed_at: 1.year.ago) }

      it 'should return the latest signature' do
        expect(CclaSignature.by_organization).to match_array([recent_signature])
      end

      it 'should not return older signatures' do
        expect(CclaSignature.by_organization).to_not match_array([old_signature])
      end
    end
  end

  describe '.earliest_by_user' do
    context 'when multiple users from a single organization have signed a CCLA' do
      let(:organization) { create(:organization, ccla_signatures_count: 0) }
      let(:repeat_signer) { create(:user, last_name: 'Repeater') }
      let!(:latest_signature) { create(:ccla_signature, organization: organization, signed_at: 1.day.ago) }
      let!(:recent_signature) do
        create(:ccla_signature, organization: organization, signed_at: 1.month.ago,
                                user: repeat_signer, last_name: repeat_signer.last_name)
      end
      let!(:recent_repeat) do
        create(:ccla_signature, organization: organization, signed_at: 1.week.ago,
                                user: repeat_signer, last_name: repeat_signer.last_name)
      end
      let!(:earliest_signature) { create(:ccla_signature, organization: organization, signed_at: 1.year.ago) }

      it 'returns the earliest signature for each of the users' do
        expect(CclaSignature.earliest_by_user).to match_array([earliest_signature, recent_signature, latest_signature])
      end

      it 'does not return an older signature by the same user' do
        expect(CclaSignature.earliest_by_user).to_not include(recent_repeat)
      end
    end
  end

  describe '.search' do
    let!(:ihop) { create(:ccla_signature, company: 'International House of Pancakes') }
    let!(:bhop) { create(:ccla_signature, company: "Bob's House of Pancakes") }

    it 'returns ccla signatures with a similar company' do
      expect(CclaSignature.search('pancakes')).to include(ihop, bhop)
    end
  end
end

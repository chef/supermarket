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
      expect(ccla_signature.persisted?).to be_true
    end
  end
end

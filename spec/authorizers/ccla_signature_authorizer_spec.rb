require 'spec_helper'

describe CclaSignatureAuthorizer do
  subject { described_class.new(user, record) }

  context 'as a Supermarket admin' do
    let(:user) { build(:user, roles: 'admin') }
    let(:record) { build(:ccla_signature) }

    it { should permit_authorization(:show) }
    it { should permit_authorization(:manage_contributors) }
  end

  context 'as an admin of the CCLA organization' do
    let!(:organization) { create(:organization) }
    let!(:user) { create(:user) }
    let!(:contributor) do
      create(
        :contributor,
        user: user,
        organization: organization,
        admin: true
      )
    end

    let(:record) { build(:ccla_signature, user: user, organization: organization) }

    it { should permit_authorization(:show) }
    it { should permit_authorization(:manage_contributors) }
  end

  context 'as a contributor on behalf of the CCLA organization' do
    let!(:organization) { create(:organization) }
    let!(:user) { create(:user) }
    let!(:contributor) do
      create(
        :contributor,
        user: user,
        organization: organization,
        admin: false
      )
    end

    let(:record) { build(:ccla_signature, user: user, organization: organization) }

    it { should permit_authorization(:show) }
    it { should_not permit_authorization(:manage_contributors) }
  end
end

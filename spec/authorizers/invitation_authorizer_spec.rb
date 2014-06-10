require 'spec_helper'

describe InvitationAuthorizer do
  let(:record) { build(:invitation) }

  subject { described_class.new(user, record) }

  context 'as an organization admin' do
    let(:user) do
      create(
        :contributor,
        admin: true,
        organization: record.organization)
      .user
    end

    it { should permit_authorization(:index) }
    it { should permit_authorization(:create) }
    it { should permit_authorization(:update) }
    it { should permit_authorization(:resend) }
    it { should permit_authorization(:revoke) }
  end

  context 'as an organization contributor' do
    let(:user) do
      create(
        :contributor,
        admin: false,
        organization: record.organization
      ).user
    end

    it { should_not permit_authorization(:index) }
    it { should_not permit_authorization(:create) }
    it { should_not permit_authorization(:update) }
    it { should_not permit_authorization(:resend) }
    it { should_not permit_authorization(:revoke) }
  end
end

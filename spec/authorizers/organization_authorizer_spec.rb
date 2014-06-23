require 'spec_helper'

describe OrganizationAuthorizer do
  let(:record) { build(:organization) }

  subject { described_class.new(user, record) }

  context 'as an organization admin' do
    let(:user) do
      create(
        :contributor,
        admin: true,
        organization: record)
      .user
    end

    it { should permit_authorization(:manage_invitations) }
  end

  context 'as an organization contributor' do
    let(:user) do
      create(
        :contributor,
        admin: false,
        organization: record
      ).user
    end

    it { should_not permit_authorization(:manage_invitations) }
  end
end

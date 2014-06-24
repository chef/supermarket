require 'spec_helper'

describe OrganizationAuthorizer do
  let(:record) { build(:organization) }

  subject { described_class.new(user, record) }

  context 'as a supermarket admin' do
    let(:user) { create(:user, roles: 'admin') }

    it { should permit_authorization(:view_cclas) }
    it { should permit_authorization(:resign_ccla) }
    it { should permit_authorization(:manage_contributors) }
  end

  context 'as an organization admin' do
    let(:user) do
      create(
        :contributor,
        admin: true,
        organization: record)
      .user
    end

    it { should permit_authorization(:view_cclas) }
    it { should permit_authorization(:resign_ccla) }
    it { should permit_authorization(:manage_contributors) }
  end

  context 'as an organization contributor' do
    let(:user) do
      create(
        :contributor,
        admin: false,
        organization: record
      ).user
    end

    it { should permit_authorization(:view_cclas) }
    it { should_not permit_authorization(:resign_ccla) }
    it { should_not permit_authorization(:manage_contributors) }
  end
end

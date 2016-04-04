require 'spec_helper'

describe OrganizationAuthorizer do
  let(:record) { build(:organization) }

  subject { described_class.new(user, record) }

  context 'as a supermarket admin' do
    let(:user) { create(:user, roles: 'admin') }

    it { should permit_authorization(:view_cclas) }
    it { should permit_authorization(:resign_ccla) }
    it { should permit_authorization(:manage_contributors) }
    it { should permit_authorization(:manage_organization) }
    it { should permit_authorization(:show) }
    it { should permit_authorization(:destroy) }
    it { should permit_authorization(:combine) }
    it { should permit_authorization(:request_to_join) }
    it { should permit_authorization(:manage_requests_to_join) }
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
    it { should permit_authorization(:manage_requests_to_join) }
    it { should_not permit_authorization(:manage_organization) }
    it { should_not permit_authorization(:show) }
    it { should_not permit_authorization(:destroy) }
    it { should_not permit_authorization(:combine) }
    it { should_not permit_authorization(:request_to_join) }
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
    it { should_not permit_authorization(:manage_organization) }
    it { should_not permit_authorization(:show) }
    it { should_not permit_authorization(:destroy) }
    it { should_not permit_authorization(:combine) }
    it { should_not permit_authorization(:request_to_join) }
    it { should_not permit_authorization(:manage_requests_to_join) }
  end

  context 'as a totally random person' do
    let(:user) { build(:user) }

    subject { described_class.new(user, record) }

    it { should_not permit_authorization(:view_cclas) }
    it { should_not permit_authorization(:resign_ccla) }
    it { should_not permit_authorization(:manage_contributors) }
    it { should_not permit_authorization(:manage_organization) }
    it { should_not permit_authorization(:show) }
    it { should_not permit_authorization(:destroy) }
    it { should_not permit_authorization(:combine) }
    it { should_not permit_authorization(:manage_requests_to_join) }
    it { should permit_authorization(:request_to_join) }
  end

  context 'as someone who already requested to join' do
    let(:user) { create(:user) }

    before do
      create(:contributor_request, user: user, organization: record)
    end

    subject { described_class.new(user, record) }

    it { should_not permit_authorization(:request_to_join) }
  end
end

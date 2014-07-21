require 'spec_helper'

describe ContributorRequestAuthorizer do
  let(:record) { create(:contributor_request) }
  let(:user) { create(:user) }

  subject { described_class.new(user, record) }

  context 'as a non-member' do
    it { should_not permit_authorization(:accept) }
    it { should_not permit_authorization(:decline) }
  end

  context 'as a member of the organization' do
    before do
      record.organization.contributors.create!(user: user)
    end

    it { should_not permit_authorization(:accept) }
    it { should_not permit_authorization(:decline) }
  end

  context 'as an admin of the organization' do
    before do
      record.organization.admins.create!(user: user)
    end

    it { should permit_authorization(:accept) }
    it { should permit_authorization(:decline) }
  end
end

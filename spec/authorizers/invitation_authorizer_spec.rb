require 'spec_helper'

describe InvitationAuthorizer do
  let(:record) { build(:invitation) }

  subject { described_class.new(user, record) }

  context 'as an organization admin' do
    let(:user) { create(:contributor, admin: true,
      organization: record.organization).user }

    it { should permit(:index) }
    it { should permit(:create) }
    it { should permit(:update) }
    it { should permit(:resend) }
  end

  context 'as an organization contributor' do
    let(:user) { create(:contributor, admin: false,
      organization: record.organization).user }

    it { should_not permit(:index) }
    it { should_not permit(:create) }
    it { should_not permit(:update) }
    it { should_not permit(:resend) }
  end
end

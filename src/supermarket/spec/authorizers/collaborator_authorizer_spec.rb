require 'spec_helper'

describe CollaboratorAuthorizer do
  let(:sally) { create(:user) }
  let(:hank) { create(:user) }
  let(:cookbook) { create(:cookbook, owner: sally) }
  let(:cookbook_collaborator) { create(:cookbook_collaborator, resourceable: cookbook, user: hank) }

  context 'as the cookbook owner' do
    subject { described_class.new(sally, cookbook_collaborator) }

    it { should permit_authorization(:transfer) }
    it { should permit_authorization(:create) }
    it { should permit_authorization(:destroy) }
  end

  context 'as a cookbook collaborator' do
    subject { described_class.new(hank, cookbook_collaborator) }

    it { should_not permit_authorization(:transfer) }
    it { should_not permit_authorization(:create) }
    it { should permit_authorization(:destroy) }
  end

  context 'as neither the owner nor a collaborator' do
    let(:pete) { create(:user) }

    subject { described_class.new(pete, cookbook_collaborator) }

    it { should_not permit_authorization(:transfer) }
    it { should_not permit_authorization(:create) }
    it { should_not permit_authorization(:destroy) }
  end

  context 'as an admin user' do
    let(:admin_user) { create(:admin) }

    subject { described_class.new(admin_user, cookbook_collaborator) }

    it { should permit_authorization(:create) }
    it { should permit_authorization(:transfer) }
    it { should permit_authorization(:destroy) }
  end
end

require 'spec_helper'

describe CookbookCollaboratorAuthorizer do
  let(:sally) { create(:user) }
  let(:hank) { create(:user) }
  let(:cookbook) { create(:cookbook, owner: sally) }
  let(:cookbook_collaborator) { create(:cookbook_collaborator, cookbook: cookbook, user: hank) }

  context 'as the cookbook owner' do
    subject { described_class.new(sally, cookbook_collaborator) }

    it { should permit(:transfer) }
    it { should permit(:create) }
    it { should permit(:destroy) }
  end

  context 'as a cookbook collaborator' do
    subject { described_class.new(hank, cookbook_collaborator) }

    it { should_not permit(:transfer) }
    it { should_not permit(:create) }
    it { should permit(:destroy) }
  end

  context 'as neither the owner nor a collaborator' do
    let(:pete) { create(:user) }

    subject { described_class.new(pete, cookbook_collaborator) }

    it { should_not permit(:transfer) }
    it { should_not permit(:create) }
    it { should_not permit(:destroy) }
  end
end

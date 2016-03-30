require 'spec_helper'

describe ToolAuthorizer do
  let(:user) { build(:user) }

  context 'as the tool owner' do
    let(:record) { build(:tool, owner: user) }

    subject { described_class.new(user, record) }

    it { should permit_authorization(:edit) }
    it { should permit_authorization(:update) }
    it { should permit_authorization(:destroy) }
    it { should permit_authorization(:create_collaborator) }
    it { should permit_authorization(:manage_adoption) }
  end

  context 'as a tool collaborator' do
    let(:record) { create(:tool) }

    subject { described_class.new(user, record) }

    before do
      create(:tool_collaborator, user: user, resourceable: record)
    end

    it { should_not permit_authorization(:destroy) }
    it { should_not permit_authorization(:create_collaborator) }
    it { should permit_authorization(:edit) }
    it { should permit_authorization(:update) }
    it { should permit_authorization(:manage) }
    it { should_not permit_authorization(:manage_adoption) }
  end

  context 'as a supermarket admin' do
    let(:user) { build(:admin) }
    let(:record) { build(:tool) }

    subject { described_class.new(user, record) }

    it { should_not permit_authorization(:create_collaborator) }
    it { should permit_authorization(:edit) }
    it { should permit_authorization(:update) }
    it { should permit_authorization(:destroy) }
    it { should permit_authorization(:manage_adoption) }
  end

  context 'not as the tool owner' do
    let(:record) { build(:tool) }

    subject { described_class.new(user, record) }

    it { should_not permit_authorization(:edit) }
    it { should_not permit_authorization(:update) }
    it { should_not permit_authorization(:destroy) }
    it { should_not permit_authorization(:create_collaborator) }
    it { should_not permit_authorization(:manage_adoption) }
  end
end

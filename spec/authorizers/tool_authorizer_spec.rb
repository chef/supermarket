require 'spec_helper'

describe ToolAuthorizer do
  let(:user) { build(:user) }

  context 'as the tool owner' do
    let(:record) { build(:tool, owner: user) }

    subject { described_class.new(user, record) }

    it { should permit_authorization(:edit) }
    it { should permit_authorization(:update) }
  end

  context 'as a supermarket admin' do
    let(:user) { build(:admin) }
    let(:record) { build(:tool) }

    subject { described_class.new(user, record) }

    it { should permit_authorization(:edit) }
    it { should permit_authorization(:update) }
  end

  context 'not as the tool owner' do
    let(:record) { build(:tool) }

    subject { described_class.new(user, record) }

    it { should_not permit_authorization(:edit) }
    it { should_not permit_authorization(:update) }
  end
end

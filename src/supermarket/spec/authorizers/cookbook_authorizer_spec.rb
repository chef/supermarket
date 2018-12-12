require 'spec_helper'

describe CookbookAuthorizer do
  let(:user) { build(:user) }

  context 'as the cookbook owner' do
    let(:record) { build(:cookbook, owner: user) }

    subject { described_class.new(user, record) }

    context 'when configuration permits owner artifact removal' do
      before { allow(ENV).to receive(:[]).with('OWNERS_CAN_REMOVE_ARTIFACTS').and_return('true') }
      it { should permit_authorization(:destroy) }
    end

    it { should permit_authorization(:create) }
    it { should_not permit_authorization(:destroy) }
    it { should permit_authorization(:create_collaborator) }
    it { should permit_authorization(:manage_cookbook_urls) }
    it { should permit_authorization(:deprecate) }
    it { should permit_authorization(:manage) }
    it { should permit_authorization(:create_collaborator) }
    it { should_not permit_authorization(:toggle_featured) }
    it { should permit_authorization(:manage_adoption) }
  end

  context 'as a cookbook collaborator' do
    let(:record) { create(:cookbook) }

    subject { described_class.new(user, record) }

    before do
      create(:cookbook_collaborator, user: user, resourceable: record)
    end

    it { should_not permit_authorization(:create_collaborator) }
    it { should_not permit_authorization(:destroy) }
    it { should_not permit_authorization(:deprecate) }
    it { should_not permit_authorization(:toggle_featured) }
    it { should permit_authorization(:create) }
    it { should permit_authorization(:manage_cookbook_urls) }
    it { should_not permit_authorization(:manage) }
    it { should_not permit_authorization(:manage_adoption) }
  end

  context 'as not the cookbook owner or a cookbook collaborator' do
    let(:record) { build(:cookbook) }

    subject { described_class.new(user, record) }

    it { should_not permit_authorization(:create) }
    it { should_not permit_authorization(:destroy) }
    it { should_not permit_authorization(:create_collaborator) }
    it { should_not permit_authorization(:manage_cookbook_urls) }
    it { should_not permit_authorization(:deprecate) }
    it { should_not permit_authorization(:toggle_featured) }
    it { should_not permit_authorization(:manage) }
    it { should_not permit_authorization(:manage_adoption) }
  end

  context 'as an admin' do
    let(:record) { build(:cookbook) }
    let(:user) { build(:admin) }

    subject { described_class.new(user, record) }

    it { should permit_authorization(:transfer_ownership) }
    it { should permit_authorization(:deprecate) }
    it { should permit_authorization(:toggle_featured) }
    it { should permit_authorization(:manage) }
    it { should_not permit_authorization(:create) }
    it { should permit_authorization(:destroy) }
    it { should permit_authorization(:create_collaborator) }
    it { should permit_authorization(:manage_cookbook_urls) }
    it { should permit_authorization(:manage_adoption) }
  end

  context 'as a cookbook owner acting on a deprecated cookbook' do
    let(:record) { build(:cookbook, owner: user, deprecated: true) }

    subject { described_class.new(user, record) }

    it { should permit_authorization(:undeprecate) }
    it { should_not permit_authorization(:deprecate) }
  end
end

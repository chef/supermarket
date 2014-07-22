require 'spec_helper'

describe CookbookAuthorizer do
  let(:user) { build(:user) }

  context 'as the cookbook owner' do
    let(:record) { build(:cookbook, owner: user) }

    subject { described_class.new(user, record) }

    it { should permit_authorization(:create) }
    it { should permit_authorization(:destroy) }
    it { should permit_authorization(:create_collaborator) }
    it { should permit_authorization(:manage_cookbook_urls) }
    it { should permit_authorization(:deprecate) }
    it { should_not permit_authorization(:toggle_featured) }
  end

  context 'as a cookbook collaborator' do
    let(:record) { create(:cookbook) }

    subject { described_class.new(user, record) }

    before do
      create(:cookbook_collaborator, user: user, cookbook: record)
    end

    it { should_not permit_authorization(:create_collaborator) }
    it { should_not permit_authorization(:destroy) }
    it { should_not permit_authorization(:deprecate) }
    it { should_not permit_authorization(:toggle_featured) }
    it { should permit_authorization(:create) }
    it { should permit_authorization(:manage_cookbook_urls) }
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
  end

  context 'as an admin' do
    let(:record) { build(:cookbook) }
    let(:user) { build(:admin) }

    subject { described_class.new(user, record) }

    it { should permit_authorization(:transfer_ownership) }
    it { should permit_authorization(:deprecate) }
    it { should permit_authorization(:toggle_featured) }
    it { should_not permit_authorization(:create) }
    it { should_not permit_authorization(:destroy) }
    it { should_not permit_authorization(:create_collaborator) }
    it { should_not permit_authorization(:manage_cookbook_urls) }
  end
end

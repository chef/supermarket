require 'spec_helper'

describe CookbookAuthorizer do
  let(:user) { build(:user) }

  context 'as the cookbook owner' do
    let(:record) { build(:cookbook, owner: user) }

    subject { described_class.new(user, record) }

    it { should permit(:create_collaborator) }
    it { should permit(:manage_cookbook_urls) }
  end

  context 'as a cookbook collaborator' do
    let(:record) { create(:cookbook) }

    subject { described_class.new(user, record) }

    before do
      create(:cookbook_collaborator, user: user, cookbook: record)
    end

    it { should_not permit(:create_collaborator) }
    it { should permit(:manage_cookbook_urls) }
  end

  context 'as not the cookbook owner or a cookbook collaborator' do
    let(:record) { build(:cookbook) }

    subject { described_class.new(user, record) }

    it { should_not permit(:create_collaborator) }
    it { should_not permit(:manage_cookbook_urls) }
  end
end

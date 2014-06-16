require 'spec_helper'

describe UserAuthorizer do
  let(:record) { build(:user) }

  context 'as an admin user' do
    let(:user) { build(:user, roles: 'admin') }
    subject { described_class.new(user, record) }

    it { should permit_authorization(:make_admin) }
    it { should permit_authorization(:revoke_admin) }
  end

  context 'as an admin user acting on another admin user' do
    let(:user) { build(:user, roles: 'admin') }
    let(:record) { build(:user, roles: 'admin') }
    subject { described_class.new(user, record) }

    it { should_not permit_authorization(:make_admin) }
    it { should permit_authorization(:revoke_admin) }
  end

  context 'as an admin user acting on themselves' do
    let(:user) { build(:user, roles: 'admin') }
    subject { described_class.new(user, user) }

    it { should_not permit_authorization(:revoke_admin) }
  end

  context 'as a non admin user' do
    let(:user) { build(:user) }
    subject { described_class.new(user, record) }

    it { should_not permit_authorization(:make_admin) }
    it { should_not permit_authorization(:revoke_admin) }
  end
end

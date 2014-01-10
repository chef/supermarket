require 'spec_helper'

describe ClaSignatureAuthorizer do
  let(:record) { build(:icla_signature) }

  subject { described_class.new(user, record) }

  context 'as an admin' do
    let(:user) { build(:user, roles: 'admin') }

    it { should permit(:index) }
    it { should permit(:show) }
    it { should permit(:create) }
    it { should permit(:update) }
    it { should permit(:destroy) }
  end

  context 'as a legal' do
    let(:user) { build(:user, roles: 'legal') }

    it { should permit(:index) }
    it { should permit(:show) }
    it { should permit(:create) }
    it { should permit(:update) }
    it { should permit(:destroy) }
  end

  context 'as an employee' do
    let(:user) { build(:user, roles: 'employee') }

    it { should permit(:index) }
    it { should permit(:show) }
    it { should_not permit(:create) }
    it { should_not permit(:update) }
    it { should_not permit(:destroy) }

    context 'when the record is owned by the user' do
      let(:record) { build(:icla_signature, user: user) }

      it { should permit(:create) }
    end
  end

  context 'as a guest' do
    let(:user) { nil }

    it { should permit(:index) }
    it { should_not permit(:show) }
    it { should_not permit(:create) }
    it { should_not permit(:update) }
    it { should_not permit(:destroy) }
  end
end

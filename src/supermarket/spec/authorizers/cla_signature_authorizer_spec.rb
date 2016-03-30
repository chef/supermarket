require 'spec_helper'

describe ClaSignatureAuthorizer do
  let(:record) { build(:icla_signature) }

  subject { described_class.new(user, record) }

  context 'as an admin' do
    let(:user) { build(:user, roles: 'admin') }

    it { should permit_authorization(:index) }
    it { should permit_authorization(:show) }
    it { should permit_authorization(:create) }
    it { should permit_authorization(:update) }
    it { should permit_authorization(:destroy) }
    it { should permit_authorization(:edit) }
    it { should permit_authorization(:new) }
  end

  context 'as a user with a cla owned by said user' do
    let(:user) { build(:user) }
    let(:record) { build(:icla_signature, user: user) }

    it { should permit_authorization(:index) }
    it { should permit_authorization(:show) }
    it { should permit_authorization(:create) }
    it { should permit_authorization(:update) }
    it { should permit_authorization(:destroy) }
    it { should permit_authorization(:edit) }
    it { should permit_authorization(:new) }
  end
end

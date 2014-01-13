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

  context 'as a user with a cla owned by said user' do
    let(:user) { build(:user) }
    let(:record) { build(:icla_signature, user: user) }

    it { should permit(:index) }
    it { should permit(:show) }
    it { should permit(:update) }
    it { should permit(:destroy) }
  end
end

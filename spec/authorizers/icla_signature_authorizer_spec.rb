require 'isolated_spec_helper'
require 'icla_signature_authorizer'

describe IclaSignatureAuthorizer do
  let(:user) { double('User') }
  let(:signature) { double('IclaSignature') }

  it 'inherits from the base CLA Signature Authorizer' do
    authorizer = IclaSignatureAuthorizer.new(user, signature)

    expect(authorizer).to be_a(ClaSignatureAuthorizer)
  end
end

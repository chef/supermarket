require 'nokogiri'
require 'spec_feature_helper'

describe 'inviting people to sign a CCLA' do
  it 'sends invited users an email prompting them to sign the CCLA and they accept' do
    sign_ccla_and_invite_admin_to('Acme')
    sign_out
    sign_in(create(:user))
    accept_invitation_to_become_admin_of('Acme')
  end

  it 'sends invited users and email prompting them to sign the CCLA and they decline' do
    sign_ccla_and_invite_admin_to('Acme')
    sign_out
    sign_in(create(:user))
    decline_invitation_to_join('Acme')
  end

end

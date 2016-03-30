require 'spec_helper'

describe 'resending an invitation to a CCLA' do
  it 'resends invited users an email prompting them to sign the CCLA' do
    sign_ccla_and_invite_admin_to('Acme')
    follow_relation 'resend_invitation'

    expect_to_see_success_message
  end
end

describe 'cancelling an invitation to a CCLA' do
  it 'removes the invitation' do
    sign_ccla_and_invite_admin_to('Acme')
    follow_relation 'revoke_invitation'

    expect_to_see_success_message
  end
end

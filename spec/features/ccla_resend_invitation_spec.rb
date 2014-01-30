require 'spec_feature_helper'

describe 'resending an invitation to a CCLA' do
  it 'resends invited users an email prompting them to sign the CCLA' do
    sign_ccla_and_invite_admin_to('Acme')
    click_link 'Resend'
    expect_to_see_success_message
  end
end

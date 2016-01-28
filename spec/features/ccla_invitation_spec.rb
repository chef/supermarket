require 'spec_helper'

describe 'inviting people to sign a CCLA' do
  let(:user) { create(:user) }

  it 'sends invited users an email prompting them to sign the CCLA and they accept' do
    sign_ccla_and_invite_admin_to('Acme')
    sign_out
    sign_in(user)
    accept_invitation_to_become_admin_of('Acme')
  end

  it 'sends invited users an email prompting them to sign the CCLA and they decline' do
    sign_ccla_and_invite_admin_to('Acme')
    sign_out
    sign_in(user)
    decline_invitation_to_join('Acme')
  end

  it "doesn't allow users to accept an invitation to a CCLA they already belong to" do
    sign_ccla_and_invite_admin_to('Acme')
    sign_out

    sign_in(user)
    accept_invitation_to_become_admin_of('Acme')
    sign_out

    sign_in(known_users[:bob])
    invite_admin('admin@example.com')
    sign_out

    sign_in(user)
    receive_and_respond_to_invitation_with('accept')

    expect_to_see_failure_message
  end
end

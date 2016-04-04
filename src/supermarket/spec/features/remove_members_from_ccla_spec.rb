require 'spec_helper'

describe 'Removing members from a CCLA' do
  example 'admins can remove another admin' do
    sign_ccla_and_invite_admin_to('Acme')

    sign_out

    sign_in(create(:user))
    accept_invitation_to_become_admin_of('Acme')
    manage_contributors
    remove_contributor_from('Acme')

    expect_to_see_success_message
  end

  example 'admins can remove other, non-admin members', use_poltergeist: true do
    sign_ccla_and_invite_contributor_to('Acme')
    sign_out
    sign_in(create(:user))
    accept_invitation_to_become_contributor_of('Acme')
    sign_out
    sign_in(known_users[:bob])
    manage_contributors
    remove_contributor_from('Acme')

    expect_to_see_success_message
  end
end

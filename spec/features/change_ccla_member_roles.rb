require 'spec_feature_helper'

describe 'Changing a members role on a CCLA' do
  example 'admins can change other users roles' do
    sign_ccla_and_invite_admin_to('Acme')
    sign_out

    sign_in(create(:user))
    accept_invitation_to_become_admin_of('Acme')
    manage_contributors

    uncheck 'contributor_admin'

    admin_checkboxes = all('#contributor_admin:checked')
    expect(admin_checkboxes.size).to eql(0)
  end
end

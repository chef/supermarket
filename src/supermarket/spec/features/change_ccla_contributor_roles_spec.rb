require 'spec_helper'

describe 'Changing a contributors role on a CCLA' do
  example 'admins can change other users roles', use_poltergeist: true do
    sign_ccla_and_invite_admin_to('Acme')
    sign_out

    sign_in(create(:user))
    accept_invitation_to_become_admin_of('Acme')
    manage_contributors

    expect(all('#contributor_admin:checked').size).to eql(1)

    within 'table' do
      uncheck 'contributor_admin'
    end

    wait_for { all('.success').present? }

    visit current_path

    expect(all('#contributor_admin:checked').size).to eql(0)
  end
end

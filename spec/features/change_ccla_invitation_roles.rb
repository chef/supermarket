require 'spec_feature_helper'

describe 'Changing a invitations role on a CCLA' do
  example 'admins can change the role of an invitation' do
    sign_ccla_and_invite_admin_to('Acme')
    manage_contributors

    expect(all('#invitation_admin:checked').size).to eql(1)

    within 'table' do
      uncheck 'invitation_admin'
    end

    visit current_path

    expect(all('#invitation_admin:checked').size).to eql(0)
  end
end

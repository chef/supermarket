require 'spec_feature_helper'

describe 'Removing members from a CCLA' do

  example 'admins can remove another admin' do
    sign_ccla_and_invite_admin_to('Acme')
    sign_out
    sign_in_with_github('12346', 'janedoe', 'janedoe@example.com')
    accept_invitation_to_become_admin_of('Acme')
    sign_out
    sign_in_with_github
    manage_contributors
    remove_contributor_from('Acme')

    admin_elements = all('.contributor.admin')

    expect(admin_elements.size).to eql(1)
  end

  example 'admins can remove other, non-admin members' do
    sign_ccla_and_invite_contributor_to('Acme')
    sign_out
    sign_in_with_github('12346', 'janedoe', 'janedoe@example.com')
    accept_invitation_to_become_contributor_of('Acme')
    sign_out
    sign_in_with_github
    manage_contributors
    remove_contributor_from('Acme')

    contributor_elements = all('.contributor')

    expect(contributor_elements.size).to eql(1)
  end

end

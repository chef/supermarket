require 'spec_feature_helper'

describe 'viewing the requests to join an organization' do
  it 'lists the pending requests' do
    user = create(:user)
    ccla_signature = create(:ccla_signature)

    create(
      :contributor,
      organization: ccla_signature.organization,
      user: user,
      admin: true
    )

    create(
      :contributor_request,
      organization: ccla_signature.organization,
      ccla_signature: ccla_signature
    )

    sign_in(user)

    follow_relation 'contributors'
    follow_relation 'companies'
    click_link 'View Contributors'
    follow_relation 'requests_to_join'

    within '.pending-requests' do
      expect(page).to have_selector('.pending-request')
    end
  end
end

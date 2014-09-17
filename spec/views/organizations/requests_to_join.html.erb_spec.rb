require 'spec_helper'

describe 'organizations/requests_to_join.html.erb' do
  before do
    policy = double(
      'policy',
      :view_cclas? => true,
      :manage_contributors? => true,
      :manage_requests_to_join? => true,
      :manage_organization? => true
    )
    allow(view).to receive(:policy).and_return(policy)
    user = create(:user, create_chef_account: false, first_name: nil, last_name: nil)
    account = create(:account, username: 'jimmeh', provider: 'chef_oauth2', user: user)
    org = create(:organization)
    pending_request = create(:contributor_request, user: user, organization: org)
    assign(:organization, org)
    assign(:pending_requests, [pending_request])
    render
  end

  it 'shows the username as a link that is never blank' do
    expect(rendered).to match(%r{<a href="/users/jimmeh">jimmeh</a> requested to join on})
  end
end

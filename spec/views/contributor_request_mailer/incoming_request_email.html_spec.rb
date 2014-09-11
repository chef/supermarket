require 'spec_helper'

describe 'contributor_request_mailer/incoming_request_email.html.erb' do
  before do
    user = create(:user)
    account = create(:account, username: 'jimmeh', provider: 'chef_oauth2', user: user)
    assign(:username, 'jimmy')
    assign(:user, user)
    assign(:organization_name, 'Acme, Inc')
    assign(:ccla_signature, create(:ccla_signature))
    assign(:contributor_request, create(:contributor_request))
  end

  it 'shows the username as a link' do
    render

    expect(rendered).to match(%r{<a href="http://test.host/users/jimmeh">jimmy</a> has requested to join})
  end
end

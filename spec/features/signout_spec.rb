require 'spec_feature_helper'

describe 'signing out' do
  it 'displays a message about oc-id' do
    sign_in(create(:user))
    sign_out

    expect(page).to have_content('id.opscode.com')
  end
end

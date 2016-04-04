require 'spec_helper'

describe 'signing in with oauth' do
  it 'signs a user in' do
    sign_in(create(:user))
    expect_to_see_success_message
  end
end

describe 'signing out with oc-id' do
  it 'signs a user out' do
    sign_in(create(:user))
    sign_out
    expect_to_see_success_message
  end
end

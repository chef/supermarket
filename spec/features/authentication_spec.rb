require 'spec_feature_helper'

describe 'signing in with oauth' do
  it 'signs a user in' do
    visit '/'
    follow_relation 'sign_in'
    expect_to_see_success_message
  end
end

describe 'signing out with oc-id' do
  it 'signs a user out' do
    sign_in
    sign_out
    expect_to_see_success_message
  end
end

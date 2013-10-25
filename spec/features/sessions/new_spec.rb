require 'spec_feature_helper'

describe 'the new session page' do
  it 'asks me to sign in' do
    visit '/'
    expect(page).to have_content 'Sign in'
  end
end

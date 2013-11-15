require 'spec_feature_helper'

describe 'the new session page' do
  it 'asks me to sign in' do
    visit sign_in_path
    expect(page).to have_content 'SIGN IN WITH'
  end
end

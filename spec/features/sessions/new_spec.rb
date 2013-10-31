require 'spec_feature_helper'

describe 'the new session page' do
  it 'asks me to login' do
    visit login_path
    expect(page).to have_content 'LOGIN WITH'
  end
end

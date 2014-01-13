require 'spec_feature_helper'

describe 'signing a CCLA' do
  before { create(:ccla) }

  it 'establishes the signer as an admin of the organization' do
    sign_in_with_github
    sign_ccla
    click_link 'View Profile'
    expect(page).to have_content 'Admin of Chef'
  end

end

require 'spec_feature_helper'

describe 'signing a CCLA' do
  before { create(:ccla) }

  it 'establishes the signer as an admin of the organization' do
    sign_in(create(:user))
    sign_ccla
    manage_agreements
    expect(page).to have_content 'Admin of Chef'
  end
end

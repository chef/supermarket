require 'spec_feature_helper'

describe 'signing a ICLA' do
  before { create(:icla) }

  it 'associates the signer with a icla' do
    sign_in(create(:user))
    sign_icla
    manage_agreements
    expect(page).to have_content 'Signed ICLA'
    expect(page).to have_no_content 'Sign ICLA'
  end
end

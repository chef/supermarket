require 'spec_feature_helper'

describe 'signing a ICLA' do
  before { create(:icla) }

  it 'associates the signer with a icla' do
    sign_in(create(:user))
    sign_icla
    click_link 'View Profile'
    expect(page).to have_content 'View ICLA'
    expect(page).to have_no_content 'Sign ICLA'
  end
end

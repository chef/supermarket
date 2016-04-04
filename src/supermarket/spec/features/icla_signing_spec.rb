require 'spec_helper'

describe 'signing a ICLA' do
  before { create(:icla) }

  it 'associates the signer with a icla' do
    sign_in(create(:user))
    sign_icla

    expect_to_see_success_message
  end
end

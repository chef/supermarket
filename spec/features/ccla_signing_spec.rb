require 'spec_helper'

describe 'signing a CCLA' do
  before { create(:ccla) }

  it 'is possible for users to sign CCLAs' do
    sign_in(create(:user))
    sign_ccla

    expect_to_see_success_message
  end
end

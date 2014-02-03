require 'spec_feature_helper'

describe 'updating a ICLA' do
  before { create(:icla) }

  it 'updates the ICLA signature' do
    sign_in(create(:user))
    sign_icla
    click_link 'View Profile'
    click_link 'Edit ICLA'

    click_button 'Update ICLA'
    expect_to_see_success_message
  end
end

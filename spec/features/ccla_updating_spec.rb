require 'spec_feature_helper'

describe 'updating a CCLA' do
  before { create(:ccla) }

  it 'updates the CCLA signature and associated Organization name' do
    sign_in(create(:user))
    sign_ccla
    click_link 'View Profile'
    click_link 'Edit CCLA'

    fill_in 'ccla_signature_organization_attributes_name', with: 'Cramer Development'
    click_button 'Update CCLA'

    expect_to_see_success_message

    click_link 'View Profile'

    expect(page).to have_content('Admin of Cramer Development')
  end
end

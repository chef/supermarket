require 'spec_feature_helper'

describe 'signing a CCLA' do

  it 'establishes the signer as an admin of the organization' do
    sign_in
    sign_ccla_as("Opscode")
    visit_profile
    expect_to_see_role('Admin of Opscode')
  end

  def sign_in
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
      provider: 'github',
      uid: '123545',
      credentials: {
        token: 'snarfle'
      },
      info: {
        email: 'foo@example.com',
        name: 'John Doe'
      }
    })

    visit '/'
    click_link 'Sign In'
    click_link 'GitHub'
  end

  def sign_ccla_as(organization_name)
    click_link "SIGN CCLA"

    fill_in 'ccla_signature_first_name', with: 'John'
    fill_in 'ccla_signature_last_name', with: 'Doe'
    fill_in 'ccla_signature_company_name', with: 'Opscode'
    fill_in 'ccla_signature_company_address', with: 'Opscode'
    fill_in 'ccla_signature_email', with: 'john@example.com'
    fill_in 'ccla_signature_phone', with: '(555) 555-5555'
    fill_in 'ccla_signature_address_line_1', with: '1 Opscode Way'
    fill_in 'ccla_signature_city', with: 'Seattle'
    fill_in 'ccla_signature_state', with: 'WA'
    fill_in 'ccla_signature_zip', with: '12345'
    fill_in 'ccla_signature_country', with: 'USA'

    check 'ccla_signature_agreement'

    find_button('Sign CCLA').click
  end

  def visit_profile
    pending
  end

  def expect_to_see_role(role)
    pending
  end

end

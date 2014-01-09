require 'spec_feature_helper'

describe 'signing a ICLA' do
  before { create(:icla) }

  it 'associates the signer with a icla' do
    sign_in
    sign_icla
    click_link 'View Profile'
    expect(page).to have_content 'View ICLA'
    expect(page).to have_no_content 'Sign ICLA'
  end

  def sign_in
    visit '/'
    click_link 'Sign In'
    click_link 'GitHub'
  end

  def sign_icla
    click_link 'Sign ICLA'

    fill_in 'icla_signature_first_name', with: 'John'
    fill_in 'icla_signature_last_name', with: 'Doe'
    fill_in 'icla_signature_company', with: 'Opscode'
    fill_in 'icla_signature_email', with: 'john@example.com'
    fill_in 'icla_signature_phone', with: '(555) 555-5555'
    fill_in 'icla_signature_address_line_1', with: '1 Opscode  Way'
    fill_in 'icla_signature_city', with: 'Seattle'
    fill_in 'icla_signature_state', with: 'WA'
    fill_in 'icla_signature_zip', with: '12345'
    fill_in 'icla_signature_country', with: 'USA'

    find("label[for='icla_signature_agreement']").click

    find_button('Sign ICLA').click
  end
end

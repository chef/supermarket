require 'spec_feature_helper'

describe 'Inviting people to sign a CCLA' do
  it 'sends invited users an email prompting them to sign the CCLA' do
    create(:ccla)
    sign_in_with_github
    sign_ccla
    click_link 'View Profile'
    click_link 'Invite Contributors'

    fill_in 'invitation_email', with: 'johndoe@example.com'
    find("label[for='invitation_admin']").click
    find_button('Send invitation').click
    expect(page).to have_content('johndoe@example.com')
    expect(page).to have_content('Admin')
  end
end

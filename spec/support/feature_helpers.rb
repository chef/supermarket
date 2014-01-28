module FeatureHelpers

  def sign_in(user)
    visit '/'
    click_link 'Sign In'

    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password

    find_button('Sign in').click
  end

  def sign_out
    click_link "Sign Out"
  end

  def sign_icla
    fill_in 'icla_signature_first_name', with: 'John'
    fill_in 'icla_signature_last_name', with: 'Doe'
    fill_in 'icla_signature_company', with: 'Chef'
    fill_in 'icla_signature_email', with: 'john@example.com'
    fill_in 'icla_signature_phone', with: '(555) 555-5555'
    fill_in 'icla_signature_address_line_1', with: '1 Chef Way'
    fill_in 'icla_signature_city', with: 'Seattle'
    fill_in 'icla_signature_state', with: 'WA'
    fill_in 'icla_signature_zip', with: '12345'
    fill_in 'icla_signature_country', with: 'USA'

    check 'icla_signature_agreement'

    find_button('Sign ICLA').click
  end

  def sign_ccla(company = "Chef")
    click_link 'Sign CCLA'
    click_link "Connect GitHub Account"

    fill_in 'ccla_signature_first_name', with: 'John'
    fill_in 'ccla_signature_last_name', with: 'Doe'
    fill_in 'ccla_signature_company', with: company
    fill_in 'ccla_signature_email', with: 'john@example.com'
    fill_in 'ccla_signature_phone', with: '(555) 555-5555'
    fill_in 'ccla_signature_address_line_1', with: '1 Chef Way'
    fill_in 'ccla_signature_city', with: 'Seattle'
    fill_in 'ccla_signature_state', with: 'WA'
    fill_in 'ccla_signature_zip', with: '12345'
    fill_in 'ccla_signature_country', with: 'USA'

    check 'ccla_signature_agreement'

    find_button('Sign CCLA').click
  end

  def sign_ccla_and_invite_admin_to(organization)
    create(:ccla)
    known_users[:bob] = create(:user)
    sign_in(known_users[:bob])
    sign_ccla(organization)
    invite_admin('admin@example.com')
  end

  def sign_ccla_and_invite_contributor_to(organization)
    create(:ccla)
    known_users[:bob] = create(:user)
    sign_in(known_users[:bob])
    sign_ccla(organization)
    invite_contributor('contributor@example.com')
  end

  def accept_invitation_to_become_admin_of(organization)
    receive_and_visit_invitation
    click_link 'Accept'
    expect(page).to have_content "Admin of #{organization}"
  end

  def accept_invitation_to_become_contributor_of(organization)
    receive_and_visit_invitation
    click_link 'Accept'
    expect(page).to have_content "Contributor of #{organization}"
  end

  def decline_invitation_to_join(organization)
    receive_and_visit_invitation
    click_link 'Decline'
    expect(page).to have_content "Declined invitation to join #{organization}"
  end

  def manage_contributors
    click_link 'View Profile'
    click_link 'Invite Contributors'
  end

  def invite_admin(email)
    manage_contributors

    fill_in 'invitation_email', with: email
    check 'invitation_admin'
    find_button('Send invitation').click
    expect(page).to have_content(email)
    expect(page).to have_content('Yes')
  end

  def invite_contributor(email)
    manage_contributors

    fill_in 'invitation_email', with: email
    find_button('Send invitation').click
    expect(page).to have_content(email)
    expect(page).to have_content('No')
  end

  def receive_and_visit_invitation
    invitation = ActionMailer::Base.deliveries.detect { |email|
      /Invitation/ =~ email['Subject'].to_s
    }

    body = invitation.parts.find { |p| p.content_type =~ /html/ }.body.to_s
    html = Nokogiri::HTML(body)
    url = html.css('a.invitation').first.attribute('href').value
    visit url
  end

  def remove_contributor_from(organization)
    click_link "Remove Contributor"
  end

  def connect_account(provider)
    click_link 'Profile'
    click_link "Connect #{provider} Account"
  end

  def known_users
    @known_users ||= { }
  end

end

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
    click_link "Sign ICLA"
    click_link "Connect GitHub Account"

    fill_in 'icla_signature_user_attributes_phone', with: '(555) 555-5555'
    fill_in 'icla_signature_user_attributes_address_line_1', with: '1 Chef Way'
    fill_in 'icla_signature_user_attributes_city', with: 'Seattle'
    fill_in 'icla_signature_user_attributes_state', with: 'WA'
    fill_in 'icla_signature_user_attributes_zip', with: '12345'
    fill_in 'icla_signature_user_attributes_country', with: 'USA'

    check 'icla_signature_agreement'

    find_button('Sign ICLA').click
  end

  def sign_ccla(company = "Chef")
    click_link 'Sign CCLA'
    click_link "Connect GitHub Account"

    fill_in 'ccla_signature_organization_attributes_name', with: company
    fill_in 'ccla_signature_organization_attributes_address_line_1', with: '1 Chef Way'
    fill_in 'ccla_signature_organization_attributes_city', with: 'Seattle'
    fill_in 'ccla_signature_organization_attributes_state', with: 'WA'
    fill_in 'ccla_signature_organization_attributes_zip', with: '12345'
    fill_in 'ccla_signature_organization_attributes_country', with: 'USA'

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
    expect_to_see_success_message
  end

  def accept_invitation_to_become_contributor_of(organization)
    receive_and_visit_invitation
    click_link 'Accept'
    expect_to_see_success_message
  end

  def decline_invitation_to_join(organization)
    receive_and_visit_invitation
    click_link 'Decline'
    expect_to_see_success_message
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

    expect_to_see_success_message
    expect(all('#invitation_admin:checked').size).to eql(1)
  end

  def invite_contributor(email)
    manage_contributors

    fill_in 'invitation_email', with: email
    find_button('Send invitation').click
    expect_to_see_success_message
    expect(all('#invitation_admin:checked').size).to eql(0)
  end

  def receive_and_visit_invitation
    invitation = ActionMailer::Base.deliveries.detect { |email|
      /Invitation/ =~ email['Subject'].to_s
    }

    ActionMailer::Base.deliveries.clear

    body = invitation.parts.find { |p| p.content_type =~ /html/ }.body.to_s
    html = Nokogiri::HTML(body)
    url = html.css('a.invitation').first.attribute('href').value
    path = URI(url).path

    visit path
  end

  def remove_contributor_from(organization)
    click_link "Remove Contributor"
  end

  def connect_account(provider)
    click_link 'Profile'
    click_link "Connect #{provider} Account"
  end

  def expect_to_see_success_message
    expect(page).to have_selector('.flash.notice')
  end

  def known_users
    @known_users ||= { }
  end

end

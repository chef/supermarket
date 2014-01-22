module FeatureHelpers

  def sign_in_with_github(uid = '12345', nickname = 'johndoe',
                          email = 'johndoe@example.com')
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
      provider: 'github',
      uid: uid,
      info: {
        nickname: nickname,
        email: email,
        name: 'John Doe',
        image: 'https://image-url.com',
      },
      credentials: {
        token: 'oauth_token',
        expires: false
      }
    })

    visit '/'
    click_link 'Sign In'
    click_link 'GitHub'
  end

  def sign_out
    click_link "Sign Out"
  end

  def sign_ccla(company = "Chef")
    click_link 'Sign CCLA'

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

    find("label[for='ccla_signature_agreement']").click

    find_button('Sign CCLA').click
  end

  def sign_ccla_and_invite_admin_to(organization)
    create(:ccla)
    sign_in_with_github
    sign_ccla(organization)
    invite_admin('admin@example.com')
  end

  def sign_ccla_and_invite_contributor_to(organization)
    create(:ccla)
    sign_in_with_github
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
    find("label[for='invitation_admin']").click
    find_button('Send invitation').click
    expect(page).to have_content(email)
    expect(page).to have_content('Admin')
  end

  def invite_contributor(email)
    manage_contributors

    fill_in 'invitation_email', with: email
    find_button('Send invitation').click
    expect(page).to have_content(email)
    expect(page).to have_content('Contributor')
  end

  def receive_and_visit_invitation
    expect(ActionMailer::Base.deliveries.size).to eql(1)

    invitation = ActionMailer::Base.deliveries.last
    body = invitation.parts.find { |p| p.content_type =~ /html/ }.body.to_s
    html = Nokogiri::HTML(body)
    url = html.css('a.invitation').first.attribute('href').value

    visit url
  ensure
    ActionMailer::Base.deliveries.clear
  end

  def remove_contributor_from(organization)
    click_link "Remove Contributor"
  end
end

module FeatureHelpers

  def sign_in(user)
    visit '/'
    click_link 'Sign In'

    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password

    find_button('Sign In').click
  end

  def sign_out
    click_link "Sign Out"
  end

  def sign_icla
    click_link "Sign ICLA"
    connect_github_account

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
    connect_github_account

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
    receive_and_respond_to_invitation_with('accept')
    expect_to_see_success_message
  end

  def accept_invitation_to_become_contributor_of(organization)
    receive_and_respond_to_invitation_with('accept')
    expect_to_see_success_message
  end

  def decline_invitation_to_join(organization)
    receive_and_respond_to_invitation_with('decline')
    expect_to_see_success_message
  end

  def manage_agreements
    click_link 'View Profile'
    click_link 'manage-profile'
    click_link 'manage-agreements'
  end

  def manage_contributors
    manage_agreements
    click_link 'invite-contributors'
  end

  def invite_admin(email)
    manage_contributors

    fill_in 'invitation_email', with: email
    check 'invitation_admin'
    find_button('Send Invite').click

    expect_to_see_success_message
    expect(all('#invitation_admin:checked').size).to eql(1)
  end

  def invite_contributor(email)
    manage_contributors

    fill_in 'invitation_email', with: email
    find_button('Send Invite').click
    expect_to_see_success_message
    expect(all('#invitation_admin:checked').size).to eql(0)
  end

  def receive_and_respond_to_invitation_with(response)
    invitation = ActionMailer::Base.deliveries.detect { |email|
      /Invitation/ =~ email['Subject'].to_s
    }.to_s

    ActionMailer::Base.deliveries.clear

    html = Nokogiri::HTML(invitation)
    url = html.css("a.#{response}").first.attribute('href').value
    path = URI(url).path

    visit path
  end

  def remove_contributor_from(organization)
    click_link "Remove Contributor"
  end

  def connect_github_account
    click_link 'connect-github'
  end

  def manage_github_accounts
    click_link 'View Profile'
    click_link 'Manage Profile'
    click_link 'manage-github-accounts'
  end

  def expect_to_see_success_message
    expect(page).to have_selector('.alert-box.success')
  end

  def known_users
    @known_users ||= { }
  end

end

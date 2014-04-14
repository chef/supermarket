module FeatureHelpers
  #
  # If +user+ is not passed it, the mock_auth defaults to the one specified in
  # the spec_helper
  #
  def sign_in(user = nil)
    if user
      configure_mock_auth(user)
    end

    visit '/'
    follow_relation 'sign_in'
  end

  def sign_out
    in_user_menu do
      follow_relation 'sign_out'
    end
  end

  def sign_icla
    in_user_menu do
      follow_relation 'sign_icla'
    end

    connect_github_account

    within '.new_icla_signature' do
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

      submit_form
    end
  end

  def sign_ccla(company = 'Chef')
    in_user_menu do
      follow_relation 'sign_ccla'
    end

    connect_github_account

    within '.new_ccla_signature' do
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

      submit_form
    end
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
    connect_github_account
    expect_to_see_success_message
  end

  def accept_invitation_to_become_contributor_of(organization)
    receive_and_respond_to_invitation_with('accept')
    connect_github_account
    expect_to_see_success_message
  end

  def decline_invitation_to_join(organization)
    receive_and_respond_to_invitation_with('decline')
    expect_to_see_success_message
  end

  def manage_profile
    in_user_menu do
      follow_relation 'view_profile'
    end

    follow_relation 'manage_profile'
  end

  def manage_agreements
    manage_profile
    follow_relation 'manage_agreements'
  end

  def manage_contributors
    manage_agreements
    follow_relation 'invite_contributors'
  end

  def invite_admin(email)
    manage_contributors

    within '.new_invitation' do
      fill_in 'invitation_email', with: email
      check 'invitation_admin'
      submit_form
    end

    expect_to_see_success_message
  end

  def invite_contributor(email)
    manage_contributors

    within '.new_invitation' do
      fill_in 'invitation_email', with: email
      submit_form
    end

    expect_to_see_success_message
    expect(all('#invitation_admin:checked').size).to eql(0)
  end

  def receive_and_respond_to_invitation_with(response)
    invitation = ActionMailer::Base.deliveries.find { |email| /invited/ =~ email['Subject'].to_s }.to_s
    ActionMailer::Base.deliveries.clear

    html = Nokogiri::HTML(invitation)
    url = html.css("a.#{response}").first.attribute('href').value
    path = URI(url).path

    visit path
  end

  def remove_contributor_from(organization)
    follow_relation 'remove_contributor'
  end

  def connect_github_account
    follow_relation 'connect_github'
  end

  def manage_github_accounts
    manage_profile
    follow_relation 'manage_github_accounts'
  end

  def manage_repositories
    in_user_menu do
      follow_relation 'manage_repositories'
    end
  end

  def expect_to_see_success_message
    expect(page).to have_selector('.alert-box.success')
  end

  def expect_to_see_failure_message
    expect(page).to have_selector('.alert-box.alert')
  end

  def known_users
    @known_users ||= {}
  end

  #
  # Finds an element with the given relation, and clicks it.
  #
  # @raise [Capybara::ElementNotFound] if the element does not exist
  #
  def follow_relation(rel)
    find("[rel*=#{rel}]").click
  end

  def relations(rel)
    all("[rel*=#{rel}]")
  end

  def submit_form
    find('[type=submit]').click
  end

  def in_user_menu
    find('.usermenu').hover
    yield
  end
end

def configure_mock_auth(user)
  OmniAuth.config.mock_auth[:chef_oauth2] = OmniAuth::AuthHash.new(
    provider: 'chef_oauth2',
    uid: user.accounts.for('chef_oauth2').first.uid,
    info: {
      nickname: 'johndoe',
      email: user.email,
      name: user.name,
      public_key: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKVuZCyYt/gLXeclgnEibmM0+o1hPNaGGls6/lFNJYa1VvoN7dNdvXIdC6cPcBAijZp/LJI6u2w0dIjo7H2lw8aYF1TgmrYzeuCy+OZjXvfk6ZCi2ls3AILsxfw8S74Gd06JB+nwYJmusF/b01Bn1ua9ywaIUpKf5ewP0aM/2nAcJn/1C+q/JyRSK0DrfajV+Tiw0jufblzx6mfvSMtFUresEAKnsmu1QJYH6aNAvBWIiz/Sh7uIBA5tHHCP43G/95tPP9wXw2Capp/aOX+PViwkGuh8ebJaYjPhV35jGGXFdUPkcHj/i14bxUVKFjUkcLataLW7DvcO4LQfZtRt0p'
    },
    credentials: {
      token: 'oauth_token',
      expires: false
    }
  )
end

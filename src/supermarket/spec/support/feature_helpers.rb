module FeatureHelpers
  #
  # If +user+ is not passed it, the mock_auth defaults to the one specified in
  # the spec_helper
  #
  def sign_in(user)
    OmniAuthControl.stub_chef!(user)
    OmniAuthControl.stub_github!(user)

    visit "/"

    within ".appnav" do
      follow_relation "sign_in"
    end
  end

  def sign_out
    in_user_menu do
      follow_relation "sign_out"
    end
  end

  def accept_invitation_to_become_admin_of(_organization)
    receive_and_respond_to_invitation_with("accept")
    connect_github_account
    expect_to_see_success_message
  end

  def accept_invitation_to_become_contributor_of(_organization)
    receive_and_respond_to_invitation_with("accept")
    connect_github_account
    expect_to_see_success_message
  end

  def decline_invitation_to_join(_organization)
    receive_and_respond_to_invitation_with("decline")
    expect_to_see_success_message
  end

  def manage_profile
    in_user_menu do
      follow_relation "view_profile"
    end

    within ".profile_sidebar" do
      follow_relation "manage_profile"
    end
  end

  def manage_agreements
    manage_profile
    follow_relation "manage_agreements"
  end

  def manage_contributors
    manage_agreements
    follow_relation "invite_contributors"
  end

  def invite_admin(email)
    manage_contributors

    within ".new_invitations" do
      fill_in "invitations_emails", with: email
      check "invitations_admin"

      Sidekiq::Testing.inline! do
        submit_form
      end
    end

    expect_to_see_success_message
  end

  def invite_contributor(email)
    manage_contributors

    within ".new_invitations" do
      fill_in "invitations_emails", with: email

      Sidekiq::Testing.inline! do
        submit_form
      end
    end

    expect_to_see_success_message
    expect(all("#invitation_admin:checked").size).to eql(0)
  end

  def receive_and_respond_to_invitation_with(response)
    invitation = ActionMailer::Base.deliveries.find { |email| /invited/ =~ email["Subject"].to_s }.to_s
    ActionMailer::Base.deliveries.clear

    html = Nokogiri::HTML(invitation)
    url = html.css("a.#{response}").first.attribute("href").value
    path = URI(url).path

    visit path
  end

  def remove_contributor_from(_organization)
    follow_relation "remove_contributor"
  end

  def connect_github_account
    follow_relation "connect_github"
  end

  def manage_github_accounts
    manage_profile
    follow_relation "manage_github_accounts"
  end

  def manage_repositories
    in_user_menu do
      follow_relation "manage_repositories"
    end
  end

  def expect_to_see_success_message
    expect(page).to have_selector(".alert-box.success")
  end

  def expect_to_see_failure_message
    expect(page).to have_selector(".alert-box.alert")
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

  def follow_first_relation(rel)
    all("[rel*=#{rel}]").first.click
  end

  def submit_form
    find("[type=submit]").click
  end

  def in_user_menu
    find(".usermenu").hover
    yield
  rescue NotImplementedError
    within(".usermenu") do
      yield
    end
  end

  #
  # Wait about five seconds for a condition to be true
  #
  def wait_for(&condition)
    ticks = 0

    loop do
      sleep 1
      ticks += 1

      break if ticks > 5
      break if yield
    end
  end
end

require 'nokogiri'
require 'spec_feature_helper'

describe 'Inviting people to sign a CCLA' do
  it 'sends invited users an email prompting them to sign the CCLA' do
    create(:ccla)
    sign_in_with_github
    sign_ccla("Acme")
    invite_admin("johndoe@example.com")
    sign_out
    accept_invitation
  end

  def accept_invitation
    expect(ActionMailer::Base.deliveries.size).to eql(1)

    invitation = ActionMailer::Base.deliveries.last
    body = invitation.parts.find { |p| p.content_type =~ /html/ }.body.to_s
    html = Nokogiri::HTML(body)
    url = html.css("a.invitation").first.attribute('href').value

    visit url

    pending "fill out the form, become a contributor"
  end

  def invite_admin(email)
    click_link 'View Profile'
    click_link 'Invite Contributors'

    fill_in 'invitation_email', with: email
    find("label[for='invitation_admin']").click
    find_button('Send invitation').click
    expect(page).to have_content(email)
    expect(page).to have_content('Admin')
  end
end

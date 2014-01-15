require 'nokogiri'
require 'spec_feature_helper'

describe 'Inviting people to sign a CCLA' do
  it 'sends invited users an email prompting them to sign the CCLA and they accept' do
    sign_ccla_and_invite_user('Acme')
    sign_out
    accept_invitation('Acme')
  end

  it 'sends invited users and email prompting them to sign the CCLA and they reject' do
    sign_ccla_and_invite_user('Acme')
    sign_out
    reject_invitation('Acme')
  end

  def sign_ccla_and_invite_user(organization)
    create(:ccla)
    sign_in_with_github
    sign_ccla(organization)
    invite_admin('johndoe@example.com')
  end

  def accept_invitation(organization)
    receive_and_visit_invitation
    click_link 'Accept'
    expect(page).to have_content "Admin of #{organization}"
  end

  def reject_invitation(organization)
    receive_and_visit_invitation
    click_link 'Reject'
    expect(page).to have_content "Successfully rejected invitation to #{organization}"
  end

  def receive_and_visit_invitation
    expect(ActionMailer::Base.deliveries.size).to eql(1)

    invitation = ActionMailer::Base.deliveries.last
    body = invitation.parts.find { |p| p.content_type =~ /html/ }.body.to_s
    html = Nokogiri::HTML(body)
    url = html.css('a.invitation').first.attribute('href').value

    visit url
    click_link 'GitHub'
  ensure
    ActionMailer::Base.deliveries.clear
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

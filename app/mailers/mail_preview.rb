class MailPreview < MailView
  def invitation_mailer
    organization = Organization.create(name: 'Chef')
    invitation = Invitation.create!(email: 'johndoe@example.com',
      organization: organization)

    mail = InvitationMailer.invitation_email(invitation)
  end
end

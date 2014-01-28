if Rails.env.development?
  class MailPreview < MailView
    def invitation_mailer
      organization = Organization.where(name: 'Chef').first_or_create
      invitation = Invitation.create!(email: 'johndoe@example.com',
        organization: organization)

      mail = InvitationMailer.invitation_email(invitation)
    end

    def cla_signature_mailer
      user = User.where(first_name: 'John', last_name: 'Doe',
        email: 'john@example.com').first_or_create!(password: 'password',
        password_confirmation: 'password')
      cla_signature = user.icla_signatures.create

      mail = ClaSignatureMailer.notification_email(cla_signature)
    end
  end
end


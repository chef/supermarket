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

      cla_signature = user.icla_signatures.where(first_name: 'John',
        last_name: 'Doe', email: 'john@example.com', phone: '888-555-5555',
        address_line_1: '123 Fake Street', city: 'Burlington',
        state: 'Vermont', zip: '05401', country: 'United States')
        .first_or_create!(agreement: '1')

      mail = ClaSignatureMailer.notification_email(cla_signature)
    end
  end
end


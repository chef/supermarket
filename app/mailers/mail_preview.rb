if Rails.env.development?
  class MailPreview < MailView
    def invitation_mailer
      mail = InvitationMailer.invitation_email(invitation)
    end

    def cla_signature_mailer
      mail = ClaSignatureMailer.notification_email(icla_signature)
    end

    private

    def organization
      organization = Organization.first_or_create
    end

    def invitation
      invitation = Invitation.where(
        email: 'johndoe@example.com',
        organization: organization
      ).first_or_create!
    end

    def ccla_signature
      user.ccla_signatures.where(
        first_name: 'John',
        last_name: 'Doe',
        email: 'john@example.com',
        phone: '888-555-5555',
        address_line_1: '123 Fake Street',
        city: 'Burlington',
        state: 'Vermont',
        zip: '05401',
        country: 'United States',
        company: 'Chef',
        organization: organization
      ).first_or_create!(agreement: '1')
    end

    def icla_signature
      user.icla_signatures.where(
        first_name: 'John',
        last_name: 'Doe',
        email: 'john@example.com',
        phone: '888-555-5555',
        address_line_1: '123 Fake Street',
        city: 'Burlington',
        state: 'Vermont',
        zip: '05401',
        country: 'United States'
      ).first_or_create!(agreement: '1')
    end

    def user
      User.where(
        first_name: 'John',
        last_name: 'Doe',
        email: 'john@example.com'
      ).first_or_create!(password: 'password', password_confirmation: 'password')
    end
  end
end


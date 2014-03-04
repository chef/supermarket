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
      ccla_signature

      invitation = Invitation.where(
        email: 'johndoe@example.com',
        organization: organization
      ).first_or_create!
    end

    def ccla_signature
      user_with_account.ccla_signatures.where(
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
      user_with_account.icla_signatures.where(
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

    def user_with_account
      user = User.where(
        first_name: 'John',
        last_name: 'Doe',
        email: 'john@example.com'
      ).first_or_create!(password: 'password', password_confirmation: 'password')

      Account.where(
        user: user,
        uid: '123',
        username: 'johndoe',
        provider: 'github',
        oauth_token: '123',
        oauth_secret: '123',
        oauth_expires: Date.parse('Tue, 20 Feb 2024')
      ).first_or_create!

      user
    end
  end
end

if Rails.env.development?
  class MailPreview < MailView
    def invitation_email
      InvitationMailer.invitation_email(invitation)
    end

    def ccla_signature_notification_email
      ClaSignatureMailer.ccla_signature_notification_email(ccla_signature)
    end

    def icla_signature_notification_email
      ClaSignatureMailer.icla_signature_notification_email(icla_signature)
    end

    def cookbook_follower_notification_email
      CookbookMailer.follower_notification_email(cookbook_follower)
    end

    def cookbook_deleted_notification_email
      CookbookMailer.cookbook_deleted_email(cookbook.name, user.email)
    end

    private

    def organization
      Organization.first!
    end

    def invitation
      organization.invitations.first!
    end

    def ccla_signature
      user.ccla_signatures.first!
    end

    def icla_signature
      user.icla_signatures.first!
    end

    def user
      User.where(email: 'john@example.com').first!
    end

    def cookbook
      Cookbook.first!
    end

    def cookbook_follower
      CookbookFollower.where(user: user).first!
    end
  end
end

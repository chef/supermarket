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

    def cookbook_deprecated_notification_email
      CookbookMailer.cookbook_deprecated_email(cookbook, cookbook_other, user.email)
    end

    def contributor_request_email
      contributor_request = ContributorRequest.where(
        user_id: user.id,
        organization_id: organization.id,
        ccla_signature_id: ccla_signature.id
      ).first_or_create

      admin = organization.admins.first.user

      ContributorRequestMailer.incoming_request_email(admin, contributor_request)
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

    def cookbook_other
      Cookbook.last!
    end

    def cookbook_follower
      CookbookFollower.where(user: user).first!
    end
  end
end

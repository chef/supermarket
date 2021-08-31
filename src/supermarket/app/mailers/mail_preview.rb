if Rails.env.development?
  class MailPreview < MailView
    def invitation_email
      InvitationMailer.invitation_email(invitation)
    end

    def cookbook_follower_notification_email
      CookbookMailer.follower_notification_email(
        cookbook.latest_cookbook_version,
        user
      )
    end

    def cookbook_deleted_notification_email
      CookbookMailer.cookbook_deleted_email(cookbook.name, user.email)
    end

    def cookbook_deprecated_notification_email
      CookbookMailer.cookbook_deprecated_email(cookbook, cookbook_other, user.email)
    end

    def collaborator_email
      CollaboratorMailer.added_email(collaborator)
    end

    private

    def organization
      Organization.first!
    end

    def invitation
      organization.invitations.first!
    end

    def user
      User.where(email: "john@example.com").first!
    end

    def cookbook
      Cookbook.first!
    end

    def cookbook_other
      Cookbook.last!
    end

    def collaborator
      Collaborator.find_or_create_by!(user: user, resourceable: cookbook)
    end
  end
end

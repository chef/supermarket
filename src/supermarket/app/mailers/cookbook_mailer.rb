class CookbookMailer < ApplicationMailer
  helper CookbookVersionsHelper

  #
  # Creates an email to a user that is a cookbook follower
  # that notifies them a new cookbook version has been published
  #
  # @param cookbook_version [CookbookVersion] the cookbook version that was
  # published
  # @param user [User] the user to notify
  #
  def follower_notification_email(cookbook_version, user)
    @cookbook_version = cookbook_version
    @email_preference = user.email_preference_for("New cookbook version")
    @to = user.email

    auto_reply_headers_off

    mail(to: @to, subject: "A new version of the #{@cookbook_version.name} cookbook has been released")
  end

  #
  # Create notification email to a cookbook's collaborators and followers
  # explaining that the cookbook has been deleted
  #
  # @param name [String] the name of the cookbook
  # @param user [User] the user to notify
  #
  def cookbook_deleted_email(name, user)
    @name = name
    @email_preference = user.email_preference_for("Cookbook deleted")
    @to = user.email

    auto_reply_headers_off

    mail(to: @to, subject: "The #{name} cookbook has been deleted")
  end

  #
  # Sends notification email to a cookbook's collaborators and followers
  # explaining that the cookbook has been deprecated in favor of another
  # cookbook
  #
  # @param cookbook [Cookbook] the cookbook
  # @param replacement_cookbook [Cookbook] the replacement cookbook
  # @param user [User] the user to notify
  #
  def cookbook_deprecated_email(cookbook, replacement_cookbook, user)
    @cookbook = cookbook
    @replacement_cookbook = replacement_cookbook
    @email_preference = user.email_preference_for("Cookbook deprecated")
    @to = user.email

    subject = "The #{@cookbook.name} cookbook has been deprecated"
    if @replacement_cookbook
      subject += " in favor of the #{@replacement_cookbook.name} cookbook"
    end

    auto_reply_headers_off

    mail(to: @to, subject: subject)
  end

  #
  # Sends email to the recipient of an OwnershipTransferRequest, asking if they
  # want to become the new owner of a Cookbook. This is generated when
  # a Cookbook owner initiates a transfer of ownership to someone that's not
  # currently a Collaborator on the Cookbook.
  #
  # @param transfer_request [OwnershipTransferRequest]
  #
  def transfer_ownership_email(transfer_request_id)
    @transfer_request = OwnershipTransferRequest.find(transfer_request_id)
    @sender = @transfer_request.sender.name
    @cookbook = @transfer_request.cookbook.name
    @add_owner_as_collaborator = if @transfer_request.add_owner_as_collaborator == true
                                   " and add themselves as a collaborator"
                                 end

    subject = %{
      #{@sender} wants to transfer ownership of the #{@cookbook} cookbook to
      you#{@add_owner_as_collaborator}.
    }.squish

    mail(to: @transfer_request.recipient.email, subject: subject)
  end
end

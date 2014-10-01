class CookbookMailer < ActionMailer::Base
  layout 'mailer'
  add_template_helper(CookbookVersionsHelper)

  #
  # Creates notification email to a cookbook follower
  # that a new cookbook version has been published
  #
  # @param cookbook_follower [CookbookFollower] the follower
  #
  def follower_notification_email(cookbook_follower)
    @cookbook = cookbook_follower.cookbook
    @to = cookbook_follower.user.email
    @unsubscribe_request = UnsubscribeRequest.create(
      user: cookbook_follower.user,
      email_preference_name: 'new_version'
    )

    mail(to: @to, subject: "A new version of the #{@cookbook.name} cookbook has been released")
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
    @to = user.email
    @unsubscribe_request = UnsubscribeRequest.create(
      user: user,
      email_preference_name: 'deleted'
    )

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
    @to = user.email
    @unsubscribe_request = UnsubscribeRequest.create(
      user: user,
      email_preference_name: 'deprecated'
    )

    subject = %(
      The #{@cookbook.name} cookbook has been deprecated in favor
      of the #{@replacement_cookbook.name} cookbook
    ).squish

    mail(to: @to, subject: subject)
  end
end

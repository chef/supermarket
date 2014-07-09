class CookbookMailer < ActionMailer::Base
  layout 'mailer'

  #
  # Creates notification email to a cookbook follower
  # that a new cookbook version has been published
  #
  # @param cookbook_follower [CookbookFollower] the follower
  #
  def follower_notification_email(cookbook_follower)
    @cookbook = cookbook_follower.cookbook
    @to = cookbook_follower.user.email

    mail(to: @to, subject: "A New Version of #{@cookbook.name} Has Been Released.")
  end

  #
  # Create notification email to a cookbook's collaborators and followers
  # explaining that the cookbook has been deleted
  #
  # @param name [String] the name of the cookbook
  # @param email [String] the user to notify
  #
  def cookbook_deleted_email(name, email)
    @name = name
    @to = email

    mail(to: @to, subject: "Chef Supermarket - The #{name} cookbook has been deleted.")
  end
end

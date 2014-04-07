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
end

class AdoptionMailer < ActionMailer::Base
  layout 'mailer'

  #
  # Sends an email to the owner of a cookbook or tool, letting them know that
  # someone is interested in taking over ownership.
  #
  # @param cookbook_or_tool [Cookbook,Tool]
  # @param user [User] the interested user
  #
  def interest_email(cookbook_or_tool, user)
    @name = cookbook_or_tool.name
    @email = user.email
    @adopting_username = user.username
    @to = cookbook_or_tool.owner.email
    @thing = cookbook_or_tool.class.name.downcase

    mail(to: @to, subject: "Interest in adopting your #{@name} #{@thing}")
  end

  def follower_email(cookbook_or_tool)
    @name = cookbook_or_tool.name
    @thing = cookbook_or_tool.class.name.downcase
    @emails = cookbook_or_tool.followers.pluck(:email)

    @emails.each do |email|
      mail(to: email, subject: "#{@name} #{@thing} up for adoption")
    end
  end
end

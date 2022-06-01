class AdoptionMailer < ApplicationMailer
  #
  # Sends an email to the owner of a cookbook or tool, letting them know that
  # someone is interested in taking over ownership.
  #
  # @param cookbook_or_tool [Cookbook,Tool]
  # @param user [User] the interested user
  #
  def interest_email(cookbook_or_tool_id, resource_class_name, user_id)
    resource_class = resource_class_name.constantize
    resource = resource_class.find_by(id: cookbook_or_tool_id)
    user = User.find(user_id)
    @name = resource.name
    @email = user.email
    @adopting_username = user.username
    @to = resource.owner.email
    @thing = resource_class_name.downcase

    mail(to: @to, subject: "Interest in adopting your #{@name} #{@thing}")
  end

  def follower_email(cookbook_or_tool_id, resource_class_name)
    resource_class = resource_class_name.constantize
    resource = resource_class.find_by(id: cookbook_or_tool_id)
    @name = resource.name
    @thing = resource.class.name.downcase
    @emails = resource.followers.pluck(:email)

    @emails.each do |email|
      mail(to: email, subject: "#{@name} #{@thing} up for adoption")
    end
  end
end

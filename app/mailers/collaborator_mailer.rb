class CollaboratorMailer < ActionMailer::Base
  layout 'mailer'

  #
  # Creates an email to send to people when they have been added as
  # a collaborator to a cookbook.
  #
  # @param cookbook_collaborator [CookbookCollaborator]
  #
  def added_email(cookbook_collaborator)
    @cookbook = cookbook_collaborator.cookbook
    user = cookbook_collaborator.user

    mail to: user.email, subject: "You have been added as a collaborator to the #{@cookbook.name} cookbook!"
  end
end

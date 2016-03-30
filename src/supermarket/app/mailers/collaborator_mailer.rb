class CollaboratorMailer < ActionMailer::Base
  layout 'mailer'

  #
  # Creates an email to send to people when they have been added as
  # a collaborator to a resource.
  #
  # @param collaborator [Collaborator]
  #
  def added_email(collaborator)
    @resource = collaborator.resourceable
    @to = collaborator.user.email

    mail(to: @to, subject: "You have been added as a collaborator to the #{@resource.name} #{@resource.class.name}")
  end
end

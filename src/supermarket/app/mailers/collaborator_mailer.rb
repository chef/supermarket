class CollaboratorMailer < ApplicationMailer
  #
  # Creates an email to send to people when they have been added as
  # a collaborator to a resource.
  #
  # @param collaborator [Collaborator]
  #
  def added_email(collaborator_id)
    collaborator = Collaborator.find(collaborator_id)
    @resource = collaborator.resourceable
    @to = collaborator.user.email

    auto_reply_headers_off

    mail(to: @to, subject: "You have been added as a collaborator to the #{@resource.name} #{@resource.class.name}")
  end
end

class InvitationMailer < ActionMailer::Base
  layout 'mailer'
  include ApplicationHelper

  #
  # Creates invitation email to invite users to a +CclaSignature+ via
  # an +Organization+
  #
  # @param invitation [Invitation] the invitation
  #
  def invitation_email(invitation)
    @invitation = invitation
    @to = invitation.email

    mail(to: @to, subject: "You have been invited to be a contributor for #{@invitation.organization.name}")
  end
end

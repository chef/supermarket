class InvitationMailer < ActionMailer::Base
  layout 'mailer'

  #
  # Creates invitation email to invite users to a +CclaSignature+ via
  # an +Organization+
  #
  # @param invitation [Invitation] the invitation
  #
  def invitation_email(invitation)
    @invitation = invitation
    @to = invitation.email

    mail(to: @to, subject: "You've been invited to sign #{@invitation.organization.name}'s CCLA")
  end
end

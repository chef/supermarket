class InvitationMailer < ActionMailer::Base
  def self.deliver_invitation(invitation)
    invitation_email(invitation).deliver
  end

  def invitation_email(invitation)
    @invitation = invitation

    mail(to: invitation.email, subject: "You've been invited to sign #{@invitation.organization.name}'s CCLA")
  end
end

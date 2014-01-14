class InvitationMailer < ActionMailer::Base
  default from: "from@example.com"

  def self.deliver_invitation(invitation)
    invitation_email(invitation).deliver
  end

  def invitation_email(invitation)
    mail(to: invitation.email)
  end
end

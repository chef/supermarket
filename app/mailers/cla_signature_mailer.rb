class ClaSignatureMailer < ActionMailer::Base
  def self.deliver_notification(cla_signature)
    notification_email(cla_signature).deliver
  end

  def notification_email(cla_signature)
    @cla_signature = cla_signature
    @to = Supermarket::Config.cla_signature_notification_email

    mail(to: @to, subject: 'New CLA Signed')
  end
end

class ClaSignatureMailer < ActionMailer::Base
  default from: "from@example.com"

  def self.deliver_notification(cla_signature)
    notification_email(cla_signature).deliver
  end

  def notification_email(cla_signature)
    @cla_signature = cla_signature
    @to = Supermarket::Config.cla_signature_notification_email

    mail(to: @to)
  end
end


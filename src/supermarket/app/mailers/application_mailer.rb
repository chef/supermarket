class ApplicationMailer < ActionMailer::Base
  layout "mailer"

  def auto_reply_headers_off
    headers("Auto-Submitted" => "auto-generated")
    headers("X-Auto-Response-Suppress" => "OOF")
  end
end

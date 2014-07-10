class ContributorRequestMailer < ActionMailer::Base
  layout 'mailer'

  def incoming_request_email(admin, _contributor_request)
    @to = admin.email

    mail(to: @to, subject: 'So-and-so wants to join your thing')
  end
end

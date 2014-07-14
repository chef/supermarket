class ContributorRequestMailer < ActionMailer::Base
  layout 'mailer'

  def incoming_request_email(admin, contributor_request)
    @to = admin.email
    @contributor_request = contributor_request
    @ccla_signature = contributor_request.ccla_signature

    @username = @contributor_request.user
    @organization_name = @contributor_request.organization.name

    subject = %(
      #{@username} has requested to join #{@organization_name} as a
      contributor
    ).squish

    mail(to: @to, subject: subject)
  end
end

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

  def request_accepted_email(contributor_request)
    @to = contributor_request.user.email
    @organization_name = contributor_request.organization.name

    subject = "Your request to join #{@organization_name} has been accepted!"

    mail(to: @to, subject: subject)
  end

  def request_declined_email(contributor_request)
    @to = contributor_request.user.email
    @organization_name = contributor_request.organization.name

    subject = "Your request to join #{@organization_name} has been declined"

    mail(to: @to, subject: subject)
  end
end

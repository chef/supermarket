class ContributorRequestMailer < ActionMailer::Base
  layout 'mailer'

  #
  # Delivers a notification that there's a pending +contributor_request+ to
  # join the given +admin+'s organization.
  #
  # @param admin [User] a user who is an admin of
  #   +contributor_request.organization+
  # @param contributor_request [ContributorRequest] a request to join an
  #   organization
  #
  def incoming_request_email(admin, contributor_request)
    @to = admin.email
    @contributor_request = contributor_request
    @user = @contributor_request.user
    @ccla_signature = contributor_request.ccla_signature

    @username = @user.username
    @organization_name = @contributor_request.organization.name

    subject = %(
      #{@username} has requested to join #{@organization_name} as a
      contributor
    ).squish

    mail(to: @to, subject: subject)
  end
end

class ClaReportMailer < ActionMailer::Base
  layout 'mailer'

  #
  # Creates CLA report email
  #
  # @param cla_report [ClaReport] the report
  #
  def report_email(cla_report)
    @cla_report = cla_report
    @to = ENV['CLA_REPORT_EMAIL']

    mail(
      to: @to,
      subject: "New CLA Report generated on #{@cla_report.created_at.to_s(:longish)}"
    )
  end
end

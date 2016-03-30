if ROLLOUT.active?(:cla) && ROLLOUT.active?(:github)
  #
  # Worker that generates and emails a CLA report if new signatures were created since the last run.
  #
  class ClaReportWorker
    include Sidekiq::Worker
    include Sidetiq::Schedulable

    recurrence { monthly }

    #
    # Generates a new CLA report if any new ICLA or CCLA signatures have been
    # signed since the last report and emails it to the configured email address.
    #
    def perform
      report = ClaReport.generate

      if report
        ClaReportMailer.report_email(report).deliver
      end
    end
  end
end

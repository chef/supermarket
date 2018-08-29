class OauthTokenRefreshScheduleWorker
  include Sidekiq::Worker

  #
  # Queue jobs for OauthTokenRefreshWorker.
  #
  # Accounts whose OAuth tokens will expire in the next 25 minutes will have
  # their tokens refreshed.
  #
  #
  def perform
    Account.tokens_expiring_soon(Time.zone.now).each do |account|
      OauthTokenRefreshWorker.perform_async(account.id)
    end
  end
end

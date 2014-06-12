class OauthTokenRefreshScheduleWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence backfill: true do
    minutes_after = (0..55).step(5)

    hourly.minute_of_hour(*minutes_after)
  end

  #
  # Queue jobs for OauthTokenRefreshWorker.
  #
  # Accounts whose OAuth tokens will expire in the next 25 minutes will have
  # their tokens refreshed.
  #
  # @param last_occurrence [Float] the time at which the previously-scheduled
  #   OauthTokenRefreshScheduleWorker ran.
  # @param current_occurrence [Float] the time at which this job was scheduled
  #   to run
  #
  # @note Sidetiq uses the arity of this method when it determines how to queue
  #   this worker's jobs. As of 2014-05-14, the +last_occurrence+ argument is
  #   only required in the sense that +perform+ must have an arity of 2. It is
  #   otherwise unused.
  #
  def perform(_last_occurrence, current_occurrence)
    lower_bound = Time.at(current_occurrence.floor)
    upper_bound = Time.at(current_occurrence.ceil + 1) + 25.minutes

    Account.
      joins(:user).
      where(oauth_expires: lower_bound..upper_bound).
      pluck(:id).
      each do |id|
        OauthTokenRefreshWorker.perform_async(id)
      end
  end
end

class UnsubscribeRequestCleanupWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily }

  #
  # Find any UnsubscribeRequests older than 6 months and delete them, to
  # prevent unbounded growth of the unsubscribe_requests table.
  #
  def perform
    UnsubscribeRequest.where('created_at < ?', 6.months.ago).delete_all
  end
end

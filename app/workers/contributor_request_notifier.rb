class ContributorRequestNotifier
  include Sidekiq::Worker

  def perform(contributor_request_id)
  end
end

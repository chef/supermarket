class Curry::RepositorySubscriptionWorker
  include Sidekiq::Worker

  def perform(repository_id)
  end
end

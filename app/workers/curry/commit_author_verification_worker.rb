class Curry::CommitAuthorVerificationWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)

    user.unverified_commit_author_identities.each do |identity|
      identity.sign_cla!
    end

    Curry::PullRequestAppraiserWorker.perform_async(user.id)
  end
end

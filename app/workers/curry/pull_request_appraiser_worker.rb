class Curry::PullRequestAppraiserWorker
  include Sidekiq::Worker

  #
  # Check if there are any Curry::UnknownCommitters with the same GitHub login
  # as the user who just signed the CLA. If there are, invoke the
  # Curry::ClaValidationWorker with the pull request that unknown committer is a
  # part of.
  #
  # @param [Integer] user_id the id for the User
  #
  def perform(user_id)
    user = User.find(user_id)
    pull_requests = user.accounts.for(:github).map(&:username).map do |login|
      Curry::UnknownCommitter.with_login(login).map(&:pull_requests)
    end.flatten.uniq

    pull_requests.each do |pull_request|
      Curry::ClaValidationWorker.perform_async(pull_request.id)
    end
  end
end

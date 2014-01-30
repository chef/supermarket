class Curry::ClaValidationWorker
  include Sidekiq::Worker

  #
  # Annotate the Pull Request specified with a +Curry::PullRequestAnnotator+.
  #
  # @param [Integer] pull_request_id the id for the Pull Request
  #
  def perform(pull_request_id)
    Curry::PullRequestAnnotator.new(
      Curry::PullRequest.find(pull_request_id)
    ).annotate
  end
end

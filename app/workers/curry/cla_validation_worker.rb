class Curry::ClaValidationWorker
  include Sidekiq::Worker

  #
  # Annotate the Pull Request specified with a +Curry::PullRequestAnnotator+.
  #
  # @param [Integer] pull_request_id the id for the Pull Request
  #
  def perform(pull_request_id)
    pull_request = Curry::PullRequest.find(pull_request_id)

    if pull_request.repository.present?
      Curry::PullRequestAnnotator.new(pull_request).annotate
    end

  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.info e

  rescue Octokit::NotFound => e
    Rails.logger.info e
  end
end

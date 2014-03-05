#
# Imports commit authors on Pull Requests who are not known to Curry. That is,
# commit authors who have not signed a CLA, or who may have signed a CLA, but
# authored commits with a non GitHub-verified email. Once the import is
# complete. This worker runs the job to annotate the given Pull Request.
#
class Curry::ImportUnknownPullRequestCommitAuthorsWorker
  include Sidekiq::Worker

  #
  # Performs the action of the worker
  #
  # @param [Integer] pull_request_id The ID of the Pull Request whose commit
  #                                  authors we want to import
  #
  def perform(pull_request_id)
    pull_request = Curry::PullRequest.find(pull_request_id)

    if pull_request.repository.present?
      Curry::ImportUnknownPullRequestCommitAuthors.new(
        pull_request
      ).import

      Curry::ClaValidationWorker.perform_async(pull_request_id)
    end
  rescue ActiveRecord::RecordNotFound
    nil
  end
end

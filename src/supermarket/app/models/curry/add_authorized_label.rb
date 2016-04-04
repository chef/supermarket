#
# Adds the ENV['CURRY_SUCCESS_LABEL'] label to a Pull Request
#
class Curry::AddAuthorizedLabel
  #
  # Creates a new +Curry::AddAuthorizedLabel+
  #
  # @param octokit [Octokit::Client]
  # @param pull_request [Curry::PullRequest]
  #
  def initialize(octokit, pull_request)
    @octokit = octokit
    @pull_request = pull_request
  end

  #
  # Performs the action of adding the label
  #
  def call
    @octokit.add_labels_to_an_issue(
      @pull_request.repository.full_name,
      @pull_request.number,
      [ENV['CURRY_SUCCESS_LABEL']]
    )
  end
end

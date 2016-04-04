#
# Assigns a reviewer to a Pull Request
#
class Curry::AssignPullRequestReviewer
  #
  # Creates a new +Curry::AssignPullRequestReviewer+
  #
  # @param octokit [Octokit::Client]
  # @param pull_request [Curry::PullRequest]
  #
  def initialize(octokit, pull_request)
    @octokit = octokit
    @pull_request = pull_request
  end

  def call
    repo_name = @pull_request.repository.full_name
    maintainer = @pull_request.repository.maintainers.sample
    return if maintainer.nil?
    gh_user = maintainer.accounts.for(:github).first.username
    if @octokit.check_assignee(repo_name, gh_user)
      @octokit.update_issue(repo_name, @pull_request.number, assignee: gh_user)
    end
    @pull_request.maintainer = maintainer
    @pull_request.save
  end
end

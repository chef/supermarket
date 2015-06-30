require 'octokit'

#
# +Curry::PullRequestAnnotator+ instances interact with GitHub Pull Requests
# based on the commit authors' signed CLA statuses. It uses the Octokit gem to
# interact with the GitHub API.
#
# The main functionality of the +Curry::PullRequestAnnotator+ is to either add a
# label to a Pull Request if all of the commit authors in a Pull Request have signed
# a CLA or to leave a comment if there are any commit authors who have not signed a
# CLA.
#
# A +Curry::PullRequestAnnotator+ is instantiated when a
# +Curry::ClaValidationWorker+ is performing its job.
#
class Curry::PullRequestAnnotator
  #
  # Creates a new annotator for the given +Curry::PullRequest+
  #
  # @param [PullRequest] pull_request
  #
  def initialize(pull_request)
    @pull_request = pull_request
    @octokit = Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
  end

  #
  # The main method for the Annotator. If all of the commit authors within a
  # pull request are signers of a CLA, add a label to the Pull Request that
  # says so. If there are any commit authors who are not signers of a CLA, add a
  # comment letting the users who have not signed a CLA know they need to
  # before the PR can be merged in.
  #
  # @note In the future it may be wise to keep track of PR state, and to only
  # carry out the annotation if the PR is still open.
  #
  def annotate
    actions = []

    unauthorized_commit_authors = @pull_request.unknown_commit_authors.to_a
    comment = @pull_request.comments.last || Curry::PullRequestComment.new

    if unauthorized_commit_authors.empty?
      actions << Curry::AddAuthorizedLabel.new(@octokit, @pull_request)
      # actions << Curry::AssignPullRequestReviewer.new(@octokit, @pull_request)

      if comment.required_authorization?
        actions << Curry::AuthorizedCommitAuthorComment.new(
          @octokit,
          @pull_request,
          unauthorized_commit_authors
        )
      end
    else
      actions << Curry::RemoveAuthorizedLabel.new(@octokit, @pull_request)

      if comment.addressed_only?(unauthorized_commit_authors)
        actions << Curry::UpdateUnauthorizedCommitAuthorComment.new(comment)
      else
        actions << Curry::UnauthorizedCommitAuthorComment.new(
          @octokit,
          @pull_request,
          unauthorized_commit_authors
        )
      end
    end

    actions.each(&:call)
  end
end

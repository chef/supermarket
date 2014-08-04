#
# Responsible for adding a comment to a Pull Request indicating
# that all commit authors are authorized to contribute
#
class Curry::AuthorizedCommitAuthorComment
  #
  # Creates a new +Curry::AuthorizedCommitAuthorComment+
  #
  # @param octokit [Octokit::Client]
  # @param pull_request [Curry::PullRequest]
  # @param unauthorized_commit_authors [Array<Curry::CommitAuthor>]
  #
  def initialize(octokit, pull_request, unauthorized_commit_authors)
    @octokit = octokit
    @pull_request = pull_request
    @unauthorized_commit_authors = unauthorized_commit_authors
  end

  #
  # Adds a comment to the given +pull_request+ and adds a record of the comment
  # internally
  #
  def call
    @octokit.add_comment(
      @pull_request.repository.full_name,
      @pull_request.number,
      comment_body
    ).tap do |comment|
      @pull_request.comments.create!(github_id: comment.id)
    end
  end

  private

  #
  # The comment text
  #
  # @return [String]
  #
  def comment_body
    %(
      Hi. Your friendly Curry bot here. Just letting you know that all commit
      authors have become authorized to contribute. I have added the
      "#{ENV['CURRY_SUCCESS_LABEL']}" label to this issue so it can easily be
      found in the future.
    ).squish
  end
end

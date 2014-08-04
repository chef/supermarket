require 'octokit'

#
# Responsible for adding a comment to a Pull Request
#
class Curry::UnauthorizedCommitAuthorComment
  #
  # Creates a new +Curry::UnauthorizedCommitAuthorComment+
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
      @pull_request.comments.new(github_id: comment.id).tap do |curry_comment|
        curry_comment.addresses!(@unauthorized_commit_authors)
      end
    end
  end

  private

  def comment_body
    [].tap do |parts|
      parts << %(
        Hi. Your friendly Curry bot here. Just letting you know that there are
        commit authors in this Pull Request who appear to not have signed a Chef
        CLA.
      ).squish

      if @unauthorized_commit_authors.any?(&:email)
        parts << %(
          There are #{@unauthorized_commit_authors.count(&:email)} commit
          author(s) whose commits are authored by a non GitHub-verified email
          address in this Pull Request. Chef will have to verify by hand that
          they have signed a Chef CLA.
        ).squish
      end

      if @unauthorized_commit_authors.any?(&:login)
        parts << 'The following GitHub users do not appear to have signed a CLA:'

        author_list = @unauthorized_commit_authors.
          select(&:login).
          map(&:login).
          map do |login|
          "* @#{login}"
        end

        parts << author_list.join("\n")
      end

      parts << "[Please sign the CLA here.](#{ENV['CURRY_CLA_LOCATION']})"
    end.join("\n\n")
  end
end

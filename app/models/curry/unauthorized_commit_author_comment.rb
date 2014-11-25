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
        Hi. I am an automated pull request bot named Curry. There are
        commits in this pull request whose authors are not yet authorized to
        contribute to Chef Software, Inc. projects or are using a non-GitHub
        verified email address. To become authorized to contribute, you will
        need to sign the Contributor License Agreement (CLA) as an individual or
        on behalf of your company. [You can read more on Chef's
        blog.](#{chef_blog_url('2014/06/23/changes-to-the-contributor-license-agreement-process')})
      ).squish

      if @unauthorized_commit_authors.any?(&:email)
        parts << '## Non-GitHub Verified Committers'
        parts << %(
          There are #{@unauthorized_commit_authors.count(&:email)} commit
          author(s) whose commits are authored by a non-GitHub verified email
          address. Chef will have to manually verify that they are authorized to
          contribute.
        ).squish
      end

      if @unauthorized_commit_authors.any?(&:login)
        parts << '## GitHub Users Who Are Not Authorized To Contribute'
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

require 'octokit'

#
# +Curry::ImportPullRequestCommitAuthors+ uses Octokit to go through a
# pull request's commit authors and creates or updates a record for each commit
# author.
#
class Curry::ImportPullRequestCommitAuthors
  #
  # Create a new instance of +Curry::ImportPullRequestCommitAuthors+.
  # This creates an instance of +Octokit::Client+ to interact with the GitHub
  # API.
  #
  # @param [Curry::PullRequest] pull_request The pull request check the commit authors of.
  #
  def initialize(pull_request)
    @pull_request = pull_request
    @repository = @pull_request.repository
    @pull_request_commits = nil
    @octokit = Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
  end

  #
  # Loop through all of the commit authors on the Pull Request. Create a record
  # for them if one does not exist, and set their +authorized_to_contribute+
  # bit regardless. Additionally, remove commit authors who were formerly
  # associated with this Pull Request.
  #
  def import_commit_authors
    ActiveRecord::Base.transaction do
      original_commit_authors = @pull_request.commit_authors.to_a

      commit_authors_identified_by_email_address.each do |commit_author|
        @pull_request.pull_request_commit_authors.where(
          commit_author_id: commit_author
        ).first_or_create!
      end

      commit_authors_identified_by_github_login.each do |commit_author|
        @pull_request.pull_request_commit_authors.where(
          commit_author_id: commit_author
        ).first_or_create!
      end

      former_commit_authors(original_commit_authors).each do |commit_author|
        @pull_request.commit_authors.delete(commit_author)
      end
    end
  end

  private

  #
  # Commit authors who authored commits that are only identifiable by the
  # author's email address
  #
  # @return [Array<Curry::CommitAuthor>]
  #
  def commit_authors_identified_by_email_address
    emails_of_non_github_verified_committers.map do |email|
      Curry::CommitAuthor.with_email(email).first_or_create!
    end
  end

  #
  # Commit authors who authored commits with a GitHub-verified email address,
  # and are thus identifiable by GitHub login
  #
  # @return [Array<Curry::CommitAuthor>]
  #
  def commit_authors_identified_by_github_login
    github_logins.map do |login|
      commit_author = Curry::CommitAuthor.with_login(login).first_or_initialize
      commit_author.authorized_to_contribute = authorized_to_contribute?(login)
      commit_author.tap(&:save!)
    end
  end

  #
  # The +Curry::CommitAuthor+ records among +original_commit_authors+ who are
  # no longer associated with this Pull Request
  #
  # @param original_commit_authors [Array<Curry::CommitAuthor>]
  #
  # @return [Array<Curry::CommitAuthor>]
  #
  def former_commit_authors(original_commit_authors)
    email_authors = original_commit_authors.select(&:email).reject do |author|
      emails_of_non_github_verified_committers.include?(author.email)
    end

    github_authors = original_commit_authors.select(&:login).reject do |author|
      github_logins.include?(author.login)
    end

    email_authors + github_authors
  end

  #
  # Returns the commits from the pull request
  #
  # @return [Array<Sawyer::Resource>]
  #
  def pull_request_commits
    @pull_request_commits ||= @octokit.pull_request_commits(
      @repository.full_name,
      @pull_request.number
    )
  end

  #
  # Returns each non GitHub-verified author email from the pull request
  #
  # @return [Array<String>]
  #
  def emails_of_non_github_verified_committers
    pull_request_commits.reject(&:author).map(&:commit).map do |commit|
      commit.author.email
    end.uniq
  end

  #
  # Returns the list of GitHub logins contributing to the pull request
  #
  # @return [Array<String>]
  #
  def github_logins
    pull_request_commits.select(&:author).map(&:author).map(&:login).uniq
  end

  #
  # Determine if the +User+ for a given GitHub login is authorized to contribute to
  # repositories that Supermarket is subscribed to. A +User+ is authorized to
  # contribute if they have an +IclaSignature+, +CclaSignature+ or are a
  # +Contributor+ on behalf of an +Organization+.
  #
  # @param [String] github_login
  #
  # @return [Boolean]
  #
  def authorized_to_contribute?(github_login)
    user = User.find_by_github_login(github_login)

    user.authorized_to_contribute?
  end
end

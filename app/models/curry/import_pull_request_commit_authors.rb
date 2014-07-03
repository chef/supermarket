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

    @octokit = Octokit::Client.new(
      access_token: ENV['GITHUB_ACCESS_TOKEN']
    )
  end

  #
  # Loop through all of the commit authors on the Pull Request. Create a record
  # for them if one does not exist, and set their +authorized_to_contribute+
  # bit regardless.
  #
  def import_commit_authors
    emails_of_non_github_verified_committers.each do |email|
      commit_author = Curry::CommitAuthor.with_email(email).first_or_create!

      @pull_request.pull_request_commit_authors.where(
        commit_author_id: commit_author.id
      ).first_or_create!
    end

    github_logins.each do |login|
      commit_author = Curry::CommitAuthor.with_login(login).first_or_initialize
      commit_author.authorized_to_contribute = authorized_to_contribute?(login)
      commit_author.save!

      @pull_request.pull_request_commit_authors.where(
        commit_author_id: commit_author.id
      ).first_or_create!
    end
  end

  private

  #
  # Returns the commits from the pull request
  #
  # @return [Array<Sawyer::Resource>]
  #
  def pull_request_commits
    @octokit.pull_request_commits(@repository.full_name, @pull_request.number)
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

    user.signed_icla? || user.contributor?
  end
end

require 'octokit'

#
# +Curry::ImportUnknownPullRequestCommitAuthors+ uses Octokit to go through a
# pull request's commit authors to see if they have signed CLAs. If the commit
# author has not signed a Supermarket CLA, a record is created for that commit
# author.
#
class Curry::ImportUnknownPullRequestCommitAuthors
  #
  # Create a new instance of +Curry::ImportUnknownPullRequestCommitAuthors+.
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
  # Loop through all of the commit authors with GitHub login or email address
  # that have not signed a CLA. Create a record for them if one does not exist.
  #
  def import
    unknown_emails.each do |email|
      commit_author = Curry::CommitAuthor.with_email(email).first_or_create!

      @pull_request.pull_request_commit_authors.where(
        commit_author_id: commit_author.id
      ).first_or_create!
    end

    unknown_github_logins.each do |login|
      commit_author = Curry::CommitAuthor.with_login(login).first_or_create!

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
  def unknown_emails
    pull_request_commits.reject(&:author).map(&:commit).map do |commit|
      commit.author.email
    end.uniq
  end

  #
  # Returns each GitHub login which is not known to have signed a CLA from the
  # pull request
  #
  # @return [Array<String>]
  #
  def unknown_github_logins
    pull_request_commits.select(&:author).map(&:author).reject do |author|
      signed_a_cla?(author.login)
    end.map(&:login).uniq
  end

  #
  # Determine if the given GitHub login has signed a CLA
  #
  # @param [String] github_login
  #
  # @return [Boolean]
  #
  def signed_a_cla?(github_login)
    User.find_by_github_login(github_login).signed_cla?
  end
end

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
  # The initializer for a new instance of a Pull Request Annotator. Requires a
  # +Curry::PullRequest+, which is used to find the +Curry::Repository+
  # for the Pull Request. An instance of +Octokit::Client+ is also created.
  #
  # @param [PullRequest] pull_request
  #
  def initialize(pull_request)
    @pull_request = pull_request
    @repository = @pull_request.repository
    @octokit = Octokit::Client.new(
      access_token: Supermarket::Config.github['access_token']
    )
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
    remove_existing_label

    if all_commit_authors_are_cla_signers?
      add_success_label
    else
      leave_failure_comment
    end
  end

  private

  #
  # Determine if all of the commit authors in the Pull Request are CLA signers.
  #
  # @return [Boolean]
  #
  def all_commit_authors_are_cla_signers?
    @pull_request.unknown_commit_authors.count.zero?
  end

  #
  # Uses Octokit to add a label to the Pull Request noting that all
  # commit authors have signed a CLA
  #
  def add_success_label
    @octokit.add_labels_to_an_issue(
      @repository.full_name,
      @pull_request.number,
      [Supermarket::Config.curry.fetch('success_label')]
    )
  end

  #
  # Uses Octokit to add a comment to the Pull Request noting which
  # GitHub users have not signed a CLA
  #
  def leave_failure_comment
    @octokit.add_comment(
      @repository.full_name,
      @pull_request.number,
      failure_message
    )
  end

  #
  # Removes the label indicating that all commit authors have signed a CLA
  #
  def remove_existing_label
    if existing_labels.include?(Supermarket::Config.curry.fetch('success_label'))
      begin
        @octokit.remove_label(
          @repository.full_name,
          @pull_request.number,
          Supermarket::Config.curry.fetch('success_label')
        )
      rescue Octokit::NotFound
        Rails.logger.info 'Octokit not found.'
      end
    end
  end

  #
  # Returns the labels the pull request currently has
  #
  def existing_labels
    @octokit.labels_for_issue(
      @repository.full_name,
      @pull_request.number
    ).map(&:name)
  end

  #
  # Build the failure message for +leave_failure_comment+ by mapping all of the
  # unsigned commiters and joining them with '@' and their GitHub login to ping
  # them on GitHub when the comment is left.
  #
  # @return [String] the message to leave on the Pull Request
  #
  def failure_message
    parts = []
    parts << %{
      Hi. Your friendly Curry bot here. Just letting you know that there are
      commit authors in this Pull Request who appear to not have signed a Chef
      CLA.
    }.squish

    unknown_commit_authors_with_email_count = @pull_request.unknown_commit_authors.with_known_email.count

    if unknown_commit_authors_with_email_count > 0
      parts << %{
        There are #{unknown_commit_authors_with_email_count} commit author(s)
        whose commits are authored by a non GitHub-verified email address in
        this Pull Request. Chef will have to verify by hand that they have
        signed a Chef CLA.
      }.squish
    end

    unknown_commit_authors_with_login = @pull_request.unknown_commit_authors.with_known_login

    if unknown_commit_authors_with_login.count > 0
      parts << 'The following GitHub users do not appear to have signed a CLA:'

      list = unknown_commit_authors_with_login.map do |commit_author|
        "* @#{commit_author.login}"
      end.join("\n")

      parts << list
    end

    parts << [
      '[Please sign the CLA here.]',
      "(#{ENV['CURRY_CLA_LOCATION']})"
    ].join

    parts.join("\n\n")
  end
end

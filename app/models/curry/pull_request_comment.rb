class Curry::PullRequestComment < ActiveRecord::Base
  scope :with_github_id, ->(id) { where(github_id: id) }

  #
  # A unique set of commit authors who are mentioned in the comment
  #
  # @return [Set<String>]
  #
  def mentioned_commit_authors
    Set.new(unauthorized_commit_authors)
  end

  #
  # Was this a comment letting folks know they need to become authorized to
  # contribute? If there were no +unauthorized_commit_authors+ stored, then no.
  # If there were +unauthorized_commit_authors+ stored, then yes.
  #
  # @return [Boolean] did this commit contain any unauthorized commit authors?
  #
  def required_authorization?
    unauthorized_commit_authors.any?
  end

  #
  # Updates the comment's +unauthorized_commit_authors+ to reflect the given
  # +commit_authors+
  #
  # @param commit_authors [Array<Curry::CommitAuthor>]
  #
  def addresses!(commit_authors)
    identifiers = commit_authors.map do |commit_author|
      [commit_author.login, commit_author.email]
    end.flatten.compact

    assign_attributes(unauthorized_commit_authors: identifiers)

    save!
  end

  #
  # Determines if this comment addressed exactly the given collection of commit
  # authors
  #
  # @param commit_authors [Array<Curry::CommitAuthor>]
  #
  # @return [Boolean]
  #
  def addressed_only?(commit_authors)
    identifiers = commit_authors.map do |commit_author|
      [commit_author.login, commit_author.email]
    end.flatten.compact

    Set.new(identifiers) == mentioned_commit_authors
  end
end

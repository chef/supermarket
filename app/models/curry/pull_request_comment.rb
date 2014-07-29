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
end

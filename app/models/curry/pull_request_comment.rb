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
end

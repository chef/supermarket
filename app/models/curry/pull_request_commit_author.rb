class Curry::PullRequestCommitAuthor < ActiveRecord::Base
  belongs_to :commit_author
  belongs_to :pull_request

  validates :commit_author_id, uniqueness: { scope: :pull_request_id }
end

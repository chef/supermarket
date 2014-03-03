class Curry::PullRequestCommitAuthor < ActiveRecord::Base
  belongs_to :commit_author
  belongs_to :pull_request
end

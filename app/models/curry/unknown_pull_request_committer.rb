class Curry::UnknownPullRequestCommitter < ActiveRecord::Base
  belongs_to :unknown_committer
  belongs_to :pull_request
end

class PullRequestsAreUniqueByRepo < ActiveRecord::Migration
  def change
    add_index :curry_pull_requests, [:number, :repository_id], unique: true
  end
end

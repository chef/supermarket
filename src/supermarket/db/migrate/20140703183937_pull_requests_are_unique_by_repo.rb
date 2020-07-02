class PullRequestsAreUniqueByRepo < ActiveRecord::Migration[4.2]
  def change
    add_index :curry_pull_requests, [:number, :repository_id], unique: true
  end
end

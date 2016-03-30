class RemoveNumberAndRepositoryIdFromPullRequestUpdate < ActiveRecord::Migration
  def change
    remove_column :curry_pull_request_updates, :number, :string
    remove_column :curry_pull_request_updates, :repository_id, :integer
  end
end

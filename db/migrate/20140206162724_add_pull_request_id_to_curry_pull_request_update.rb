class AddPullRequestIdToCurryPullRequestUpdate < ActiveRecord::Migration
  def change
    add_column :curry_pull_request_updates, :pull_request_id, :integer, null: false
  end
end

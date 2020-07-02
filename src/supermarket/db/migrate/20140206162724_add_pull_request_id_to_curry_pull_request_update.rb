class AddPullRequestIdToCurryPullRequestUpdate < ActiveRecord::Migration[4.2]
  def change
    add_column :curry_pull_request_updates, :pull_request_id, :integer, null: false
  end
end

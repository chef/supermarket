class CreateCurryPullRequestComments < ActiveRecord::Migration
  def change
    create_table :curry_pull_request_comments do |t|
      t.integer :github_id, null: false
      t.integer :pull_request_id, null: false

      t.timestamps
    end

    add_index :curry_pull_request_comments, :pull_request_id
    add_index :curry_pull_request_comments, :github_id, unique: true
  end
end

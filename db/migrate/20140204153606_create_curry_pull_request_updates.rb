class CreateCurryPullRequestUpdates < ActiveRecord::Migration
  def change
    create_table :curry_pull_request_updates do |t|
      t.text :payload, null: false

      t.timestamps
    end
  end
end

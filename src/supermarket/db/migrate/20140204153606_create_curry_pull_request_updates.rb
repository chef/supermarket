class CreateCurryPullRequestUpdates < ActiveRecord::Migration[4.2]
  def change
    create_table :curry_pull_request_updates do |t|
      t.text :payload, null: false

      t.timestamps
    end
  end
end

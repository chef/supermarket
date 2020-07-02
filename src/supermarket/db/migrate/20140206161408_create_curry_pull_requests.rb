class CreateCurryPullRequests < ActiveRecord::Migration[4.2]
  def change
    create_table :curry_pull_requests do |t|
      t.string :number, null: false
      t.integer :repository_id, index: true, null: false

      t.timestamps
    end
  end
end

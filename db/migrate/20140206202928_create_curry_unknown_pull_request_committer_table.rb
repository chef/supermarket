class CreateCurryUnknownPullRequestCommitterTable < ActiveRecord::Migration
  def change
    create_table :curry_unknown_pull_request_committers do |t|
      t.integer :pull_request_id, index: true, null: false
      t.integer :unknown_committer_id, index: true, null: false
    end
  end
end

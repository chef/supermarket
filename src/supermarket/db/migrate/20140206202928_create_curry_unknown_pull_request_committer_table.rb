class CreateCurryUnknownPullRequestCommitterTable < ActiveRecord::Migration
  def change
    create_table :curry_unknown_pull_request_committers do |t|
      t.integer :pull_request_id, index: true, null: false
      t.integer :unknown_committer_id, index: {name: 'idx_curry_unk_pull_request_committers_unk_committer_id'}, null: false
    end
  end
end

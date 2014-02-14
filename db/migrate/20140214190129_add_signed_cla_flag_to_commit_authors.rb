class AddSignedClaFlagToCommitAuthors < ActiveRecord::Migration
  def change
    change_table :curry_commit_authors do |t|
      t.boolean :signed_cla, null: false, default: false
    end
  end
end

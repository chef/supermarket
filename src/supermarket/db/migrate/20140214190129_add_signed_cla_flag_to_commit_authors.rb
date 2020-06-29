class AddSignedClaFlagToCommitAuthors < ActiveRecord::Migration[4.2]
  def change
    change_table :curry_commit_authors do |t|
      t.boolean :signed_cla, null: false, default: false
    end
  end
end

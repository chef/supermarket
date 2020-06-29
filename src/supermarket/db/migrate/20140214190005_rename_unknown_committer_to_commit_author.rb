class RenameUnknownCommitterToCommitAuthor < ActiveRecord::Migration[4.2]
  def change
    rename_table :curry_unknown_committers, :curry_commit_authors
  end
end

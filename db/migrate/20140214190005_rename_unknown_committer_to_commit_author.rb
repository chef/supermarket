class RenameUnknownCommitterToCommitAuthor < ActiveRecord::Migration
  def change
    rename_table :curry_unknown_committers, :curry_commit_authors
  end
end

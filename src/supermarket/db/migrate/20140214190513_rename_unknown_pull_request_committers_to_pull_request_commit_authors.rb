class RenameUnknownPullRequestCommittersToPullRequestCommitAuthors < ActiveRecord::Migration
  def change
    rename_table :curry_unknown_pull_request_committers, :curry_pull_request_commit_authors
  end
end

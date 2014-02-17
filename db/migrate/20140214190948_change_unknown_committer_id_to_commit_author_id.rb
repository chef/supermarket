class ChangeUnknownCommitterIdToCommitAuthorId < ActiveRecord::Migration
  def change
    rename_column :curry_pull_request_commit_authors, :unknown_committer_id, :commit_author_id
  end
end
